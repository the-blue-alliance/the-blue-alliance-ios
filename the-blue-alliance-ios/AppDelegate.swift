//
//  AppDelegate.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import CoreData
import TBAKit

public enum StatusConstants {
    static let currentSeasonKey = "current_season"
    static let downEventsKey = "down_events"
    static let latestAppVersionKey = "latest_app_version"
    static let minAppVersionKey = "min_app_version"
    static let isDatafeedDownKey = "is_datafeed_down"
    static let maxSeasonKey = "max_season"
}

extension TBAStatus {

    public static func defaultStatus() -> TBAStatus {
        let currentYear = Calendar.current.year

        let defaultStatusJSON: [String: Any] = [
            "android": [
                "latest_app_version": -1,
                "min_app_version": -1
            ],
            "current_season": currentYear,
            "down_events": [],
            "ios": [
                "latest_app_version": -1,
                "min_app_version": -1
            ],
            "is_datafeed_down": false,
            "max_season": currentYear
        ]
        return try! TBAStatus(json: defaultStatusJSON)
    }

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TBA")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Call our staus endpoint and save everything in NSUserDefaults - can we KVO these when they change?
        // TOOD: Maybe move this to applicationDidBecomeActive
        
        TBAStatus.fetchStatus { (status, error) in
            if let error = error {
                print("Erorr fetching TBA status: \(error)")
            }
            
            // TODO: We need to write some error handling to setup defaults here if we're written to these keys already or not
            UserDefaults.standard.set(status?.currentSeason, forKey: StatusConstants.currentSeasonKey)
            UserDefaults.standard.set(status?.downEvents, forKey: StatusConstants.downEventsKey)
            // Note: We can update these two keys as we ship future versions, along with some migration code
            UserDefaults.standard.set(status?.iosInfo.latestAppVersion, forKey: StatusConstants.latestAppVersionKey)
            UserDefaults.standard.set(status?.iosInfo.minAppVersion, forKey: StatusConstants.minAppVersionKey)
            UserDefaults.standard.set(status?.datafeedDown, forKey: StatusConstants.isDatafeedDownKey)
            UserDefaults.standard.set(status?.maxSeason, forKey: StatusConstants.maxSeasonKey)
        }
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        
        let tabBarController = splitViewController.viewControllers[0] as! UITabBarController
        for vc in tabBarController.viewControllers! {
            guard let nav = vc as? UINavigationController else {
                continue
            }
            // TODO: Pass down to ALL view controllers... but first they need to share a protocol
            guard let dataVC = nav.viewControllers.first as? EventsTableViewController else {
                continue
            }
            dataVC.persistentContainer = self.persistentContainer
        }
 
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

