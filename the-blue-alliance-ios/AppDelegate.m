//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"
#import "TBAPersistenceController.h"
#import "TBAKit.h"
#import "TeamsViewController.h"
#import "EventRanking.h"
#import "Team.h"
#import "Event.h"

@interface AppDelegate ()

@property (strong, readwrite) TBAPersistenceController *persistenceController;

@end

@implementation AppDelegate

#pragma mark - Main Entry Point

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setPersistenceController:[[TBAPersistenceController alloc] initWithCallback:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"RootTabBarController"];

        for (UINavigationController *nav in rootTabBarController.viewControllers) {
            TBAViewController *vc = (TBAViewController *)[nav.viewControllers firstObject];
            vc.persistenceController = self.persistenceController;
        }

        UIView *overlayView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
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
    
#warning We should probably set some max's here or something
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    [self setupAppearance];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[self persistenceController] save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[self persistenceController] save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[self persistenceController] save];
}


#pragma mark - Interface Methods

- (void)setupAppearance {    
    [[UINavigationBar appearance] setBarTintColor:[UIColor TBANavigationBarColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UIToolbar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexColor:[UIColor TBANavigationBarColor]];
}

@end
