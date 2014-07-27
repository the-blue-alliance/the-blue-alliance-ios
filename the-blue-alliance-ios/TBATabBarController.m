//
//  TBATabBarController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/26/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBATabBarController.h"
#import "TBAImporter.h"

@interface TBATabBarController ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UIManagedDocument *document;

@end

@implementation TBATabBarController



- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    for (id controller in self.viewControllers) {
        if([controller respondsToSelector:@selector(setContext:)]) {
            [controller setContext:self.context];
        } else if([controller isKindOfClass:[UINavigationController class]]) {
            id realController = [controller viewControllers][0];
            if([realController respondsToSelector:@selector(setContext:)]) {
                [realController setContext:self.context];
            }
        }
    }
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createOrOpenDatabase];
}



@end
