//
//  TBAPersistenceController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAPersistenceController.h"

@interface TBAPersistenceController ()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, readwrite) NSManagedObjectContext *backgroundManagedObjectContext;

@property (copy) InitCallbackBlock initCallback;

- (void)initializeCoreData;

@end

@implementation TBAPersistenceController

- (id)initWithCallback:(InitCallbackBlock)callback;
{
    if (!(self = [super init]))
        return nil;
    
    [self setInitCallback:callback];
    [self initializeCoreData];
    
    return self;
}

- (void)initializeCoreData {
    if ([self managedObjectContext])
        return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TBA" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = psc;
    
    self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.backgroundManagedObjectContext.parentContext = self.managedObjectContext;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"TBA.sqlite"];

        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{@"journal_mode": @"DELETE"};

        NSError *error;
        NSPersistentStoreCoordinator *psc = self.managedObjectContext.persistentStoreCoordinator;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        
        if (!self.initCallback)
            return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.initCallback();
        });
    });
}

- (void)performChanges:(void (^)())block {
    [self.backgroundManagedObjectContext performBlock:^{
        block();
        [self save];
    }];
}

- (void)save {
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *backgroundError;
        NSAssert([self.backgroundManagedObjectContext save:&backgroundError], @"Failed to save background context: %@\n%@", backgroundError.localizedDescription, backgroundError.userInfo);
        if (backgroundError) {
            [self.backgroundManagedObjectContext rollback];
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                NSError *mainError;
                NSAssert([self.managedObjectContext save:&mainError], @"Failed to save main context: %@\n%@", mainError.localizedDescription, mainError.userInfo);
                if (mainError) {
                    [self.managedObjectContext rollback];
                } 
            }];
        }
    }];
}

@end
