import SwiftUI
import TBAAPI
import UIKit

@main
struct TBAApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase

    private let api: TBAAPI
    private let statusService: StatusService

    @State private var status: Status

    init() {
        let secrets = Secrets()
        api = TBAAPI(apiKey: secrets.tbaAPIKey)
        statusService = StatusService(api: api, userDefaults: .standard)
        status = statusService.status
        // TODO: Kickoff an initial refresh, possibly?
    }

    var body: some Scene {
        WindowGroup {
            PhoneView()
        }
        .onChange(of: statusService.status) {
            status = statusService.status
        }
        .environment(\.api, api)
        .environment(\.status, status)
    }
}

import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    // MARK: - UIApplicationDelegate

    // For later, when we need to delete our old Core Data store...
    /*
     lazy var persistentContainer: TBAPersistenceContainer = {
         let persistentContainer = TBAPersistenceContainer()
         persistentContainer.persistentStoreDescriptions.forEach {
             $0.type = NSSQLiteStoreType
         }
         return persistentContainer
     }()
     */

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /*
         for url in FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask) {
             let coreDataURL = url.appendingPathComponent("TBA.sqlite")
             if FileManager.default.fileExists(atPath: coreDataURL.path) {
                 do {
                     try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: coreDataURL, ofType: "sqlite", options: nil)
                 } catch {
                     // TODO: Log some error, break
                 }
             }
         }
         */

        /*
         // Setup our Firebase app - make sure this is called before other Firebase setup
         FirebaseApp.configure()

         // Disable Crashlytics during debug
         #if DEBUG
         Analytics.setAnalyticsCollectionEnabled(false)
         Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
         #else
         Analytics.setAnalyticsCollectionEnabled(true)
         Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
         #endif
         */

        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                print("didBecomeActiveNotification")
            }
        }
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification) {
                print("didEnterBackgroundNotification")
            }
        }
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.willTerminateNotification) {
                print("willTerminateNotification")
            }
        }

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    // MARK: Private Methods

    private func setupWindow(_: UIWindow) {
        Task {
            // TODO: Show/register for isDatafeedDown
        }
    }
}

/*
 private class TBAErrorRecorder: ErrorRecorder {

     func log(_ format: String, _ args: [CVarArg]) {
         #if DEBUG
         print(String(format: format, arguments: args))
         #else
         Crashlytics.crashlytics().log(format: format, arguments: getVaList(args))
         #endif
     }

     func record(_ error: Error) {
         #if DEBUG
         print(error)
         #else
         Crashlytics.crashlytics().record(error: error)
         #endif
     }

 }
 */

// For later, when we need to delete our old Core Data store...
/*
 import CoreData

 let AppGroupIdentifier = "group.com.the-blue-alliance.tba.tbadata"

 public class TBAPersistenceContainer: NSPersistentContainer {

     override open class func defaultDirectoryURL() -> URL {
         if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier) {
             return appGroupURL
         }
         return super.defaultDirectoryURL()
     }

     private static let managedObjectModel: NSManagedObjectModel? = {
         return NSManagedObjectModel.mergedModel(from: [Bundle.module])
     } ()

     override public init(name: String, managedObjectModel model: NSManagedObjectModel) {
         super.init(name: name, managedObjectModel: model)
     }

     public init() {
         guard let managedObjectModel = TBAPersistenceContainer.managedObjectModel else {
             fatalError("Could not load model")
         }
         super.init(name: "TBA", managedObjectModel: managedObjectModel)
     }

 }
 */
