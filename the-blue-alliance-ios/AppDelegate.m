//
//  AppDelegate.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AppDelegate.h"
#import "REFrostedViewController.h"
#import "EventsViewController.h"
#import "Event+Create.h"

@interface AppDelegate () <NSURLConnectionDataDelegate>

// Database variables
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) EventsViewController *eventsViewController;
@end

@implementation AppDelegate

#pragma mark - Custom getters / setters
- (void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
    self.eventsViewController.context = context;
}

#pragma mark - Core Data Setup
- (void) documentIsReady
{
    if(self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
        
        // Register for save notifications: useful for debugging
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseSaved:) name:NSManagedObjectContextDidSaveNotification object:self.context];
        
        [self downloadEventsIntoDatabase];
    }
}

- (void) databaseSaved:(NSNotification *)note
{
    NSLog(@"Database saved");
}

- (void) createOrOpenDatabase
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

#pragma mark - TBA Data downloading
- (void) downloadEventsIntoDatabase
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

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

#pragma mark - Main Entry Point
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create content view controller, and put into a navigation controller
    self.eventsViewController = [[EventsViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.eventsViewController];
    
    UITableViewController *menuController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    // Create frosted view controller
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:navigationController menuViewController:menuController];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    
    // Create a simple menu button
    [self.eventsViewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:frostedViewController action:@selector(presentMenuViewController)]];
    
    // Make the side menu controller the root controller
    self.window.rootViewController = frostedViewController;
    
    
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
