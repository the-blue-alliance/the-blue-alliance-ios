//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"

#import "EventsTableViewController.h"
#import "TeamsTableViewController.h"
#import "InsightsViewController.h"
#import "SettingsViewController.h"

#import "Event+Create.h"

#import <TWTSideMenuViewController/TWTSideMenuViewController.h>
#import <MZFormSheetController/MZFormSheetController.h>

#import "FBTweakShakeWindow.h"
#import "FBTweakInline.h"
#import "TBAImporter.h"


@interface AppDelegate () <NSURLConnectionDataDelegate, MenuViewControllerDelegate>

// Database variables
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuController;

// Top level view controllers
@property (nonatomic, strong) UINavigationController *topNavigationController;
@property (nonatomic, strong) EventsTableViewController *eventsViewController;
@property (nonatomic, strong) TeamsTableViewController *teamsViewController;
@property (nonatomic, strong) InsightsViewController *insightsViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@end

@implementation AppDelegate

#pragma mark - Custom getters / setters
// Lazily instantiate the top level view controllers
- (EventsTableViewController *)eventsViewController
{
    if (!_eventsViewController) {
        _eventsViewController = [[EventsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [_eventsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)]];
    }
    return _eventsViewController;
}
- (TeamsTableViewController *)teamsViewController
{
    if (!_teamsViewController) {
        _teamsViewController = [[TeamsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [_teamsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)]];
    }
    return _teamsViewController;
}
- (InsightsViewController *)insightsViewController
{
    if (!_insightsViewController) {
        _insightsViewController = [[InsightsViewController alloc] init];
        [_insightsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)]];
    }
    return _insightsViewController;
}
- (SettingsViewController *)settingsViewController
{
    if (!_settingsViewController) {
        _settingsViewController = [[SettingsViewController alloc] init];
        [_settingsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)]];
    }
    return _settingsViewController;
}


- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    self.eventsViewController.context = context;
    self.teamsViewController.context = context;
}

#pragma mark - Core Data Setup
- (void)documentIsReady
{
    if(self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
        
        // Register for save notifications: useful for debugging
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseSaved:) name:NSManagedObjectContextDidSaveNotification object:self.context];
        
        [TBAImporter importEventsUsingManagedObjectContext:self.context];
        [TBAImporter importTeamsUsingManagedObjectContext:self.context];
    }
}

- (void)databaseSaved:(NSNotification *)note
{
    NSLog(@"Database saved");
}

- (void)createOrOpenDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"database";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    self.document.persistentStoreOptions = options;
    
    BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
    if(fileExists) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                NSLog(@"Opened document at %@", url);
                [self documentIsReady];
            } else {
                NSLog(@"FAILED to open document at %@", url);
                NSLog(@"Model is probably out of sync with the database: Just uninstall the app and run again...");
            }
        }];
    } else {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success) {
                NSLog(@"Saved document at %@", url);
                [self documentIsReady];
            } else {
                NSLog(@"Failed to save document at %@", url);
            }
        }];
    }
}

#pragma mark - Menu Actions
- (void)menuButtonPressed
{
    // Make sure to dismiss keyboard when menu is opened
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [self.sideMenuController openMenuAnimated:YES completion:nil];
}

- (void)menuViewController:(MenuViewController *)menu didSelectMenuItem:(NSString *)menuItem
{
    UIViewController *chosenViewController = nil;
    if([menuItem isEqualToString:@"Events"]) {
        chosenViewController = self.eventsViewController;
    } else if([menuItem isEqualToString:@"Teams"]) {
        chosenViewController = self.teamsViewController;
    } else if([menuItem isEqualToString:@"Insights"]) {
        chosenViewController = self.insightsViewController;
    } else {
        chosenViewController = self.settingsViewController;
    }
    [self.topNavigationController setViewControllers:@[chosenViewController] animated:YES];
    
    [self.sideMenuController closeMenuAnimated:YES completion:nil];
}

#pragma mark - Main Entry Point
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#if DEBUG
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTweaks:) name:@"FBTweakChanged" object:nil];
#endif
    
    // Setup UI appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor TBANavigationBarColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIToolbar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    [[UITableView appearance] setSectionIndexColor:[UIColor TBANavigationBarColor]];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    
    self.window = [[FBTweakShakeWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.tintColor = [UIColor TBATintColor];
    
    // Create content view controller, and put into a navigation controller
    self.topNavigationController = [[UINavigationController alloc] initWithRootViewController:self.eventsViewController];
    self.topNavigationController.navigationBar.translucent = NO;
    
    MenuViewController *menuController = [[MenuViewController alloc] initWithMenuItems:@[@"Events", @"Teams", @"Insights", @"Settings"]];
    menuController.delegate = self;
    
    // Create side menu view controller
    self.sideMenuController = [[TWTSideMenuViewController alloc] initWithMenuViewController:menuController mainViewController:self.topNavigationController];
    self.sideMenuController.shadowColor = [UIColor blackColor];
    self.sideMenuController.edgeOffset = UIOffsetMake(18.0f, 0.0f);
    self.sideMenuController.zoomScale = 0.5634f;
    self.sideMenuController.animationDuration = 0.35;
    
    // set the side menu controller as the root view controller
    self.window.rootViewController = self.sideMenuController;
    
    // Set a background gradient for the menu
    UIColor *topColor = [UIColor colorWithRed:0.122 green:0.134 blue:0.293 alpha:1.000];
    UIColor *bottomColor = [UIColor colorWithRed:0.173 green:0.178 blue:0.227 alpha:1.000];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.window.bounds;
    gradient.colors = @[(id)[topColor CGColor], (id)[bottomColor CGColor]];
    [self.sideMenuController.view.layer insertSublayer:gradient atIndex:0];
    
    // Initialize database
    [self createOrOpenDatabase]; // This will call documentIsReady when complete!
    
    return YES;
}

- (void) updateTweaks:(NSNotification *)note
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor TBANavigationBarColor]];
    self.window.tintColor = [UIColor TBATintColor];
    if([self.topNavigationController.visibleViewController isKindOfClass:[UITableViewController class]]) {
        [((UITableViewController *)self.topNavigationController.visibleViewController).tableView reloadData];
    }
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
