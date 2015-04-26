//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <NSURLConnectionDataDelegate>

@end


@implementation AppDelegate

#pragma mark - Main Entry Point

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    // Setup UI appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor TBANavigationBarColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UIToolbar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexColor:[UIColor TBANavigationBarColor]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
