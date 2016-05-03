//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"
#import "TBAPersistenceController.h"
#import "TBAViewController.h"
#import "TBANavigationController.h"
#import "TBANavigationControllerDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TBAPersistenceController *persistenceController;
@property (nonatomic, strong) TBANavigationControllerDelegate *navigationDelegate;

@end

@implementation AppDelegate

#pragma mark - Main Entry Point

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setPersistenceController:[[TBAPersistenceController alloc] initWithCallback:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"RootTabBarController"];
        self.navigationDelegate = [[TBANavigationControllerDelegate alloc] init];
        
        for (TBANavigationController *nav in rootTabBarController.viewControllers) {
            nav.delegate = self.navigationDelegate;
            nav.persistenceController = self.persistenceController;
        }

        // Doing all this nonsense so we can set up view controller's persistence controllers before they try to
        // query for any kind of data. There's a bit of a flash when launching but it's not too bad.
        UIViewController *launchViewController = [storyboard instantiateViewControllerWithIdentifier:@"Launch"];
        UIView *overlayView = launchViewController.view;
        [rootTabBarController.view addSubview:overlayView];
        self.window.rootViewController = rootTabBarController;
        
        [UIView animateWithDuration:0.75f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            overlayView.alpha = 0;
        } completion:^(BOOL finished) {
            [overlayView removeFromSuperview];
        }];
    }]];

#warning dynaically fetch version number here, also maybe add some user-specific string?
    [[TBAKit sharedKit] setIdHeader:@"the-blue-alliance:ios:v0.1"];
    
    [self setupAppearance];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.persistenceController save:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.persistenceController save:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.persistenceController save:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    return YES;
}

#pragma mark - Interface Methods

- (void)setupAppearance {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[TBANavigationController class]]];
    [navigationBarAppearance setTranslucent:NO];
    [navigationBarAppearance setBarTintColor:[UIColor primaryBlue]];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    [navigationBarAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
    [navigationBarAppearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
}

@end
