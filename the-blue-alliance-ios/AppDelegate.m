//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"

#import "EventsViewController.h"
#import "TeamsViewController.h"
#import "InsightsViewController.h"
#import "SettingsViewController.h"

#import "Event+Create.h"

#import <TWTSideMenuViewController/TWTSideMenuViewController.h>


@interface AppDelegate () <NSURLConnectionDataDelegate, MenuViewControllerDelegate>

// Database variables
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuController;

// Top level view controllers
@property (nonatomic, strong) UINavigationController *topNavigationController;
@property (nonatomic, strong) EventsViewController *eventsViewController;
@property (nonatomic, strong) TeamsViewController *teamsViewController;
@property (nonatomic, strong) InsightsViewController *insightsViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@end

@implementation AppDelegate

#pragma mark - Custom getters / setters
// Lazily instantiate the top level view controllers
- (EventsViewController *)eventsViewController
{
    if (!_eventsViewController) {
        _eventsViewController = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
        [_eventsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)]];
    }
    return _eventsViewController;
}
- (TeamsViewController *)teamsViewController
{
    if (!_teamsViewController) {
        _teamsViewController = [[TeamsViewController alloc] initWithStyle:UITableViewStylePlain];
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
}

#pragma mark - Core Data Setup
- (void)documentIsReady
{
    if(self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
        
        // Register for save notifications: useful for debugging
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseSaved:) name:NSManagedObjectContextDidSaveNotification object:self.context];
        
        [self downloadEventsIntoDatabase];
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
    
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
    if(fileExists) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                NSLog(@"Opened document at %@", url);
                [self documentIsReady];
            } else {
                NSLog(@"FAILED to open document at %@", url);
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

// What is this?
- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    NSLog(@"Handle this error - %@", [error localizedDescription]);
}

#pragma mark - TBA Data downloading
- (void)downloadEventsIntoDatabase
{
    NSURL *eventsListURL = [NSURL URLWithString:@"http://www.thebluealliance.com/api/v2/events/"];
    NSMutableURLRequest *eventsRequest = [NSMutableURLRequest requestWithURL:eventsListURL];
    [eventsRequest addValue:@"tba-ios:tba-ios-app:v0.1" forHTTPHeaderField:@"X-TBA-App-Id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:eventsRequest returningResponse:&response error:&error];
        if(error || !data) {
            NSLog(@"ERROR downloading event list from TBA: %@", error);
        } else {
            NSArray *events = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if(error || !events) {
                NSLog(@"ERROR: %@ parsing JSON of event list: %@", error, data);
            } else {
                // Import the events array into the database!
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Event createEventsFromTBAInfoArray:events usingManagedObjectContext:self.context];
                });
            }
        }
    });
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
        chosenViewController = self.eventsViewController;
    } else if([menuItem isEqualToString:@"Insights"]) {
        chosenViewController = self.eventsViewController;
    } else if([menuItem isEqualToString:@"Settings"]) {
        chosenViewController = self.eventsViewController;
    }
    [self.topNavigationController setViewControllers:@[chosenViewController] animated:YES];
    
    [self.sideMenuController closeMenuAnimated:YES completion:nil];
}

#pragma mark - Main Entry Point
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup UI appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor TBANavigationBarColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
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
    [self.window.layer insertSublayer:gradient atIndex:0];
    
    // Initialize database
    [self createOrOpenDatabase]; // This will call documentIsReady when complete!

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
