//
//  TBAPersistenceController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAPersistenceController.h"
#import "TBAMyTBAAuthentication.h"
#import "Valet.h"

static NSString *const MyTBAKeychainKey = @"myTBAKeychainItem";

@interface TBAPersistenceController ()

@property (nonatomic, strong) VALValet *keychainValet;
@property (nonatomic, strong) TBAMyTBAAuthentication *authentication;

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, readwrite) NSManagedObjectContext *backgroundManagedObjectContext;

@property (copy) InitCallbackBlock initCallback;

- (void)initializeCoreData;

@end

@implementation TBAPersistenceController
@synthesize authentication = _authentication;

#pragma mark - Properities

- (VALValet *)keychainValet {
    if (!_keychainValet) {
        _keychainValet = [[VALValet alloc] initWithIdentifier:@"MyTBA" accessibility:VALAccessibilityAlways];
    }
    return _keychainValet;
}

#pragma mark - Initilization

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
    [self performChanges:block withCompletion:nil];
}

- (void)performChanges:(void (^)())block withCompletion:(void (^)())completion {
    [self.backgroundManagedObjectContext performBlock:^{
        block();
        [self save:completion];
    }];
}

- (void)save:(void (^)())completion {
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *backgroundError;
        NSAssert([self.backgroundManagedObjectContext save:&backgroundError], @"Failed to save background context: %@\n%@", backgroundError.localizedDescription, backgroundError.userInfo);
        if (backgroundError) {
            [self.backgroundManagedObjectContext rollback];
            if (completion) {
                completion();
            }
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                NSError *mainError;
                NSAssert([self.managedObjectContext save:&mainError], @"Failed to save main context: %@\n%@", mainError.localizedDescription, mainError.userInfo);
                if (mainError) {
                    [self.managedObjectContext rollback];
                }
                if (completion) {
                    completion();
                }
            }];
        }
    }];
}

#pragma mark - MyTBA Authentication

- (void)setAuthentication:(TBAMyTBAAuthentication *)authentication {
    _authentication = authentication;
    
    if (authentication) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authentication];
        [self.keychainValet setObject:data forKey:MyTBAKeychainKey];
    } else {
        [self.keychainValet removeObjectForKey:MyTBAKeychainKey];
    }
}

- (TBAMyTBAAuthentication *)authentication {
    if (!_authentication) {
        NSData *data = [self.keychainValet objectForKey:MyTBAKeychainKey];
        if (data) {
            _authentication = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return _authentication;
}

@end
