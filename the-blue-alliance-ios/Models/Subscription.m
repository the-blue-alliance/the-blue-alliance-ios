//
//  Subscription.m
//  the-blue-alliance
//
//  Created by Zach Orr on 9/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Subscription.h"
#import "Event.h"
#import "Team.h"
#import "Match.h"

@implementation Subscription

@dynamic deviceKey;
@dynamic modelKey;
@dynamic modelType;
@dynamic notifications;

+ (instancetype)insertSubscriptionWithModelSubscription:(TBASubscription *)modelSubscription inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modelKey == %@", modelSubscription.modelKey];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Subscription *subscription) {
        subscription.deviceKey = modelSubscription.deviceKey;
        subscription.modelKey = modelSubscription.modelKey;
        subscription.modelType = @(modelSubscription.modelType);
        subscription.notifications = modelSubscription.notifications;
        
        // Insert stub models so we can have something to reference later
        if (modelSubscription.modelType == TBAMyTBAModelTypeTeam) {
            [Team insertStubTeamWithKey:subscription.modelKey inManagedObjectContext:context];
        } else if (modelSubscription.modelType == TBAMyTBAModelTypeEvent) {
            // If it's a * event (all event for year), we don't need to insert an event, since * is abstract and
            // represents *all* events for a year
            if (![subscription.modelKey containsString:@"*"]) {
                [Event insertStubEventWithKey:subscription.modelKey inManagedObjectContext:context];
            }
        } else if (modelSubscription.modelType == TBAMyTBAModelTypeMatch) {
            [Match insertStubMatchWithKey:subscription.modelKey inManagedObjectContext:context];
        }
    }];
}

+ (NSArray<Subscription *> *)insertSubscriptionsWithModelSubscriptions:(NSArray<TBASubscription *> *)modelSubscriptions inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBASubscription *modelSubscription in modelSubscriptions) {
        [arr addObject:[self insertSubscriptionWithModelSubscription:modelSubscription inManagedObjectContext:context]];
    }
    return arr;
}

@end
