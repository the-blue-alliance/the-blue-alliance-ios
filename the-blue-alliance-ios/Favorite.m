//
//  Favorite.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/29/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Favorite.h"
#import "TBAFavorite.h"

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
