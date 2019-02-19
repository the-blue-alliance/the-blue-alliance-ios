import Crashlytics
import Foundation
import React
import Firebase
import Zip

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

    private static var forceRedownloadKeys = ["v1.0.4"]

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

    private var needsForcedRedownload: Bool {
        return ReactNativeService.forceRedownloadKeys.contains { (key) -> Bool in
            return !userDefaults.bool(forKey: key)
        }
    }

    func markForcedRedownload() {
        ReactNativeService.forceRedownloadKeys.filter({ !userDefaults.bool(forKey: $0) }).forEach({
            userDefaults.set(true, forKey: $0)
        })
        userDefaults.synchronize()
    }

    private var fileManager: FileManager
    private var firebaseStorage: Storage
    private var firebaseOptions: FirebaseOptions?
    private var metadata: ReactNativeMetadata
    internal var retryService: RetryService
    private var userDefaults: UserDefaults

    init(fileManager: FileManager, firebaseStorage: Storage, firebaseOptions: FirebaseOptions?, metadata: ReactNativeMetadata, retryService: RetryService, userDefaults: UserDefaults) {
        self.fileManager = fileManager
        self.firebaseStorage = firebaseStorage
        self.firebaseOptions = firebaseOptions
        self.metadata = metadata
        self.retryService = retryService
        self.userDefaults = userDefaults
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
        do {
            try cleanupCompressedBundle()
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            return
        }

        guard let remoteBundleReference = remoteBundleReference else {
            assertionFailure("No remote bundle found - make sure Firebase is setup before updating RN")
            return
        }

        // Check if we need to download a new compressed React Native bundle,
        // or if the version we have is the most recent
        remoteBundleReference.getMetadata { [unowned self] (metadata, error) in
            if let error = error {
                print("Unable to fetch metadata for compressed React Native bundle: \(error.localizedDescription)")
                Crashlytics.sharedInstance().recordError(error)
            } else if let metadata = metadata {
                let needsDownload = (Int(metadata.generation) > self.metadata.bundleGeneration || self.needsForcedRedownload)
                // If this is our first launch, our bundleGeneration will be 0
                let needsMarkForcedDownload = (self.metadata.bundleGeneration == 0 || self.needsForcedRedownload)

                // Download if we need to force a redownload, or if the local version is outdated
                if needsDownload {
                    self.downloadReactNativeBundle(remoteBundleReference: remoteBundleReference) { (error) in
                        if let error = error {
                            Crashlytics.sharedInstance().recordError(error)
                        } else {
                            if needsMarkForcedDownload {
                                self.markForcedRedownload()
                            }
                            self.updateMetadata(storageMetadata: metadata)
                        }
                    }
                }
            } else {
                print("Unable to fetch metadata for compressed React Native bundle")
            }
        }
    }

    private func downloadReactNativeBundle(remoteBundleReference: StorageReference, completion: @escaping (Error?) -> Void) {
        remoteBundleReference.write(toFile: compressedBundleURL, completion: { [unowned self] (url, error) in
            var downloadError: Error?
            if let error = error {
                downloadError = error
            } else {
                do {
                    try self.unzipCompressedBundle()
                    try self.cleanupCompressedBundle()
                } catch {
                    downloadError = error
                }
            }
            completion(downloadError)
        })
    }

    private func updateMetadata(storageMetadata: StorageMetadata) {
        self.metadata.bundleGeneration = Int(storageMetadata.generation)
        self.metadata.bundleCreated = storageMetadata.timeCreated
    }

    private var safeToDelete: Bool {
        // Check if we have an old compressed bundle to cleanup
        let reachable = (try? compressedBundleURL.checkResourceIsReachable()) ?? false
        if !reachable {
            return false
        }

        // Ensure we have an uncompressed bundle file and assets folder
        let check: [URL?] = [bundleURL, assetsURL]
        let safeToDelete = check.reduce(true) { (result, checkURL) -> Bool in
            return result && (checkURL.reachableURL != nil)
        }

        return safeToDelete
    }

    private func cleanupCompressedBundle() throws {
        if safeToDelete {
            try fileManager.removeItem(at: compressedBundleURL)
        }
    }

    private func unzipCompressedBundle() throws {
        try Zip.unzipFile(compressedBundleURL,
                      destination: documentDirectory,
                      overwrite: true,
                      password: nil)
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
