import Foundation
import React
import Firebase
import ZIPFoundation

protocol ReactNativeMetadataObservable {
    func metadataUpdated()
}

class ReactNativeMetadata {

    private var userDefaults: UserDefaults

    var metadataProvider = Provider<ReactNativeMetadataObservable>()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    private enum DefaultKeys: String {
        case bundleGeneration = "kReactNativeBundleGenerationKey"
        case bundleCreated = "kReactNativeBundleCreatedKey"
    }

    var bundleGeneration: Int {
        get {
            return userDefaults.integer(forKey: DefaultKeys.bundleGeneration.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: DefaultKeys.bundleGeneration.rawValue)
            userDefaults.synchronize()

            metadataProvider.post(block: { $0.metadataUpdated() })
        }
    }

    var bundleCreated: Date? {
        get {
            return userDefaults.object(forKey: DefaultKeys.bundleCreated.rawValue) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: DefaultKeys.bundleCreated.rawValue)
            userDefaults.synchronize()

            metadataProvider.post(block: { $0.metadataUpdated() })
        }
    }

}

class ReactNativeService {

    enum BundleName: String {
        case assets = "ios/assets"
        case downloaded = "ios/main.jsbundle"
        case compressed = "react-native.zip"
    }

    fileprivate var documentDirectory: URL {
        return try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    fileprivate var compressedBundleURL: URL {
        return documentDirectory.appendingPathComponent(BundleName.compressed.rawValue)
    }
    fileprivate var bundleURL: URL {
        return documentDirectory.appendingPathComponent(BundleName.downloaded.rawValue)
    }
    fileprivate var assetsURL: URL {
        return documentDirectory.appendingPathComponent(BundleName.compressed.rawValue)
    }

    private var fileManager: FileManager
    private var firebaseStorage: Storage
    private var firebaseOptions: FirebaseOptions?
    private var metadata: ReactNativeMetadata
    internal var retryService: RetryService

    init(fileManager: FileManager,  firebaseStorage: Storage, firebaseOptions: FirebaseOptions?, metadata: ReactNativeMetadata, retryService: RetryService) {
        self.fileManager = fileManager
        self.firebaseStorage = firebaseStorage
        self.firebaseOptions = firebaseOptions
        self.metadata = metadata
        self.retryService = retryService
    }

    private var remoteBundleReference: StorageReference? {
        guard let storageBucket = firebaseOptions?.storageBucket else {
            assertionFailure("Storage bucket nil - check GoogleService-Info.plist")
            return nil
        }
        return firebaseStorage.reference(forURL: String(format: "gs://%@/react-native/%@",
                                                        storageBucket,
                                                        BundleName.compressed.rawValue))
    }

    public func updateReactNativeBundle() {
        // Check if we have an orphaned compressed bundle that needs to be cleaned up (or unzipped)
        cleanupCompressedBundle()

        guard let remoteBundleReference = remoteBundleReference else {
            assertionFailure("No remote bundle found - make sure Firebase is setup before updating RN")
            return
        }

        // Check if we need to download a new compressed React Native bundle, or if the version we have is the most recent
        remoteBundleReference.getMetadata { [unowned self] (metadata, error) in
            if let error = error {
                print("Unable to fetch metadata for compressed React Native bundle: \(error.localizedDescription)")
            } else if let metadata = metadata, Int(metadata.generation) > self.metadata.bundleGeneration {
                // Download the newest React Native bundle
                self.downloadReactNativeBundle(completion: { (error) in
                    if error == nil {
                        self.metadata.bundleGeneration = Int(metadata.generation)
                        self.metadata.bundleCreated = metadata.timeCreated
                    }
                })
            }
        }
    }

    private func downloadReactNativeBundle(completion: @escaping (Error?) -> Void) {
        guard let remoteBundleReference = remoteBundleReference else {
            assertionFailure("No remote bundle found - make sure Firebase is setup before updating RN")
            return
        }

        remoteBundleReference.write(toFile: compressedBundleURL, completion: { [unowned self] (url, error) in
            if let error = error {
                print("Error writing compressed React Native bundle to filesystem: \(error.localizedDescription)")
            } else if url != nil {
                self.unzipCompressedBundle()
                self.cleanupCompressedBundle()
            }
            completion(error)
        })
    }

    private func cleanupCompressedBundle() {
        // Check if we have an old compressed bundle to cleanup
        let reachable = (try? compressedBundleURL.checkResourceIsReachable()) ?? false
        if !reachable {
            return
        }

        // Ensure we have an uncompressed bundle file and assets folder
        let check: [URL?] = [bundleURL, assetsURL]
        let safeToDelete = check.reduce(true) { (result, checkURL) -> Bool in
            return result && (checkURL.reachableURL != nil)
        }

        // If we don't have the uncompressed files we need, attempt to uncompress them
        // Otherwise, go ahead and clean up the compressed bundle we don't need anymore
        if safeToDelete {
            try? fileManager.removeItem(at: compressedBundleURL)
        } else {
            unzipCompressedBundle()
        }
    }

    private func unzipCompressedBundle() {
        try? fileManager.unzipItem(at: compressedBundleURL, to: documentDirectory)
    }

}

extension ReactNativeService: Retryable {
    var retryInterval: TimeInterval {
        // Poll for new RN bundle every 15 mins
        return 60 * 15
    }

    func retry() {
        updateReactNativeBundle()
    }


}
