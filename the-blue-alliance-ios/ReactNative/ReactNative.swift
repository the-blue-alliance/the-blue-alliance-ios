import Foundation
import React
import Firebase
import ZIPFoundation

enum BundleName: String {
    case assets = "assets"
    case downloaded = "main.jsbundle"
    case compressed = "ios.zip"
}

enum DefaultKeys: String {
    case bundleGeneration = "kReactNativeBundleGenerationKey"
}

private var bundleGeneration: Int {
    get {
        return UserDefaults.standard.integer(forKey: DefaultKeys.bundleGeneration.rawValue)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: DefaultKeys.bundleGeneration.rawValue)
        UserDefaults.standard.synchronize()
    }
}

private var documentDirectory: URL? {
    return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}
private var compressedBundleURL: URL? {
    return documentDirectory?.appendingPathComponent(BundleName.compressed.rawValue)
}
private var bundleURL: URL? {
    return documentDirectory?.appendingPathComponent(BundleName.downloaded.rawValue)
}
private var assetsURL: URL? {
    return documentDirectory?.appendingPathComponent(BundleName.compressed.rawValue)
}

// TODO: I can't seem to implement sourceURLForBridge: and fallbackSourceURLForBridge: in a protocol extension...
protocol ReactNative: RCTBridgeDelegate {
    var reactBridge: RCTBridge { get }
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
        if let bundleURL = bundleURL.reachableURL {
            return bundleURL
        }
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
    }

}

class ReactNativeDownloader {
    
    private static var remoteBundleReference: StorageReference {
        // TODO: Swap this for a prod url
        let storageBucket = FirebaseOptions.defaultOptions()?.storageBucket ?? "zach-tba-dev.appspot.com"
        let storage = Storage.storage()
        return storage.reference(forURL: String(format: "gs://%@/react-native/%@", storageBucket, BundleName.compressed.rawValue))
    }
    
    public static func updateReactNativeBundle() {
        // Check if we have an orphaned compressed bundle that needs to be cleaned up (or unzipped)
        cleanupCompressedBundle()
        
        // Check if we need to download a new compressed React Native bundle, or if the version we have is the most recent
        remoteBundleReference.getMetadata { (metadata, error) in
            if let error = error {
                print("Unable to fetch metadata for compressed React Native bundle: \(error.localizedDescription)")
            } else if let metadata = metadata, Int(metadata.generation) > bundleGeneration {
                // Download the newest React Native bundle
                downloadReactNativeBundle(completion: { (error) in
                    if error == nil {
                        bundleGeneration = Int(metadata.generation)
                    }
                })
            }
        }
    }
    
    private static func downloadReactNativeBundle(completion: @escaping (Error?) -> ()) {
        guard let compressedBundleURL = compressedBundleURL else {
            return
        }

        remoteBundleReference.write(toFile: compressedBundleURL, completion: { (url, error) in
            if let error = error {
                print("Error writing compressed React Native bundle to filesystem: \(error.localizedDescription)")
            } else if url != nil, unzipCompressedBundle() == true {
                cleanupCompressedBundle()
            }
            completion(error)
        })
    }
    
    private static func cleanupCompressedBundle() {
        // Check if we have an old compressed bundle to cleanup
        guard let compressedBundleURL = compressedBundleURL.reachableURL else {
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
        try? FileManager.default.removeItem(at: compressedBundleURL)
    }
    
    // Returns true if unzip successful
    private static func unzipCompressedBundle() -> Bool {
        guard let documentDirectory = documentDirectory, let compressedBundleURL = compressedBundleURL else {
            return false
        }
        return (try? FileManager.default.unzipItem(at: compressedBundleURL, to: documentDirectory)) != nil
    }

}
