//
//  Subscription.h
//  the-blue-alliance
//
//  Created by Zach Orr on 9/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class TBASubscription;

NS_ASSUME_NONNULL_BEGIN

@interface Subscription : TBAManagedObject

@property (nonatomic, retain) NSString *deviceKey;
@property (nonatomic, retain) NSString *modelKey;
@property (nonatomic, retain) NSNumber *modelType;
@property (nonatomic, retain) NSArray<NSString *> *notifications;

+ (instancetype)insertSubscriptionWithModelSubscription:(TBASubscription *)modelSubscription inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Subscription *> *)insertSubscriptionsWithModelSubscriptions:(NSArray<TBASubscription *> *)modelSubscriptions inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
