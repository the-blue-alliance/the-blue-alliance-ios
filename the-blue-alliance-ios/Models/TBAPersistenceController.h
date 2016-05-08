//
//  TBAPersistenceController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^InitCallbackBlock)(void);

@class TBAMyTBAAuthentication;

@interface TBAPersistenceController : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

- (id)initWithCallback:(InitCallbackBlock)callback;

- (void)performChanges:(void (^)())block;
- (void)performChanges:(void (^)())block withCompletion:(void (^)())completion;
- (void)save:(void (^)())completion;

- (void)setAuthentication:(TBAMyTBAAuthentication *)authentication;
- (TBAMyTBAAuthentication *)authentication;

@end
