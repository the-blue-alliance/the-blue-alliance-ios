import Foundation
import React
import Firebase
import ZIPFoundation
import Crashlytics

// TODO: I can't seem to implement sourceURLForBridge: and fallbackSourceURLForBridge: in a protocol extension...
protocol ReactNative: RCTBridgeDelegate {
    var reactBridge: RCTBridge { get }

    func showErrorView()
}

extension ReactNative {

    var sourceURL: URL {
        #if DEBUG
        return debugSourceURL
        #else
        return prodSourceURL
        #endif
    }

    fileprivate var debugSourceURL: URL {
        let debugSourceURL = URL(string: "http://localhost:8081/index.ios.bundle")
        if let debugSourceURL = debugSourceURL.reachableURL {
            return debugSourceURL
        }
        return prodSourceURL
    }

    var prodSourceURL: URL {
        let fallbackURL = Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return fallbackURL
        }

        let bundleURL = documentsDirectory.appendingPathComponent(ReactNativeService.BundleName.downloaded.rawValue)
        if let reachable = try? bundleURL.checkResourceIsReachable(), reachable == false {
            return fallbackURL
        }

        return bundleURL
    }

    func reactNativeError(_ sender: NSNotification) {
        if let error = sender.userInfo?["error"] as? Error {
            Crashlytics.sharedInstance().recordError(error)
        }
        showErrorView()
    }

}

class ReactNativeService {

    fileprivate enum BundleName: String {
        case assets = "assets"
        case downloaded = "main.jsbundle"
        case compressed = "ios.zip"
    }

    private enum DefaultKeys: String {
        case bundleGeneration = "kReactNativeBundleGenerationKey"
    }

    fileprivate var bundleGeneration: Int {
        get {
            return userDefaults.integer(forKey: DefaultKeys.bundleGeneration.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: DefaultKeys.bundleGeneration.rawValue)
            userDefaults.synchronize()
        }
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

    var userDefaults: UserDefaults
    var fileManager: FileManager
    var firebaseStorage: Storage
    var firebaseOptions: FirebaseOptions
    var retryService: RetryService

    init(userDefaults: UserDefaults, fileManager: FileManager,  firebaseStorage: Storage, firebaseOptions: FirebaseOptions, retryService: RetryService) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        self.firebaseStorage = firebaseStorage
        self.firebaseOptions = firebaseOptions
        self.retryService = retryService
    }

    private var remoteBundleReference: StorageReference? {
        guard let storageBucket = firebaseOptions.storageBucket else {
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
        remoteBundleReference.getMetadata { [weak self] (metadata, error) in
            if let error = error {
                print("Unable to fetch metadata for compressed React Native bundle: \(error.localizedDescription)")
            } else if let metadata = metadata, let bundleGeneration = self?.bundleGeneration, Int(metadata.generation) > bundleGeneration {
                // Download the newest React Native bundle
                self?.downloadReactNativeBundle(completion: { (error) in
                    if error == nil {
                        self?.bundleGeneration = Int(metadata.generation)
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

        remoteBundleReference.write(toFile: compressedBundleURL, completion: { [weak self] (url, error) in
            if let error = error {
                print("Error writing compressed React Native bundle to filesystem: \(error.localizedDescription)")
            } else if url != nil, self?.unzipCompressedBundle() == true {
                self?.cleanupCompressedBundle()
            }
            completion(error)
        })
    }

    private func cleanupCompressedBundle() {
        // Check if we have an old compressed bundle to cleanup
        if let reachable = try? compressedBundleURL.checkResourceIsReachable(), reachable == false {
            return
        }

        // Ensure we have an uncompressed bundle file and assets folder
        let check: [URL?] = [bundleURL, assetsURL]
        let safeToDelete = check.reduce(true) { (result, checkURL) -> Bool in
            return result && (checkURL.reachableURL != nil)
        }

        // If we don't have the uncompressed files we need, attempt to uncompress them
        if safeToDelete == false, unzipCompressedBundle() == false {
            return
        }
        try? fileManager.removeItem(at: compressedBundleURL)
    }

    // Returns true if unzip successful
    private func unzipCompressedBundle() -> Bool {
        return (try? fileManager.unzipItem(at: compressedBundleURL, to: documentDirectory)) != nil
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
