//
//  Favorite.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/29/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Favorite.h"
#import "TBAFavorite.h"
#import "Event.h"
#import "Team.h"
#import "Match.h"

@implementation Favorite

@dynamic deviceKey;
@dynamic modelKey;
@dynamic modelType;

+ (instancetype)insertFavoriteWithModelFavorite:(TBAFavorite *)modelFavorite inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modelKey == %@", modelFavorite.modelKey];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Favorite *favorite) {
        favorite.deviceKey = modelFavorite.deviceKey;
        favorite.modelKey = modelFavorite.modelKey;
        favorite.modelType = @(modelFavorite.modelType);
        
        // Insert stub models so we can have something to reference later
        if (modelFavorite.modelType == TBAMyTBAModelTypeTeam) {
            [Team insertStubTeamWithKey:favorite.modelKey inManagedObjectContext:context];
        } else if (modelFavorite.modelType == TBAMyTBAModelTypeEvent) {
            // If it's a * event (all event for year), we don't need to insert an event, since * is abstract and
            // represents *all* events for a year
            if (![favorite.modelKey containsString:@"*"]) {
                [Event insertStubEventWithKey:favorite.modelKey inManagedObjectContext:context];
            }
        } else if (modelFavorite.modelType == TBAMyTBAModelTypeMatch) {
            [Match insertStubMatchWithKey:favorite.modelKey inManagedObjectContext:context];
        }
    }];
}

+ (NSArray<Favorite *> *)insertFavoritesWithModelFavorites:(NSArray<TBAFavorite *> *)modelFavorites inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAFavorite *modelFavorite in modelFavorites) {
        [arr addObject:[self insertFavoriteWithModelFavorite:modelFavorite inManagedObjectContext:context]];
    }
    return arr;
}

@end
