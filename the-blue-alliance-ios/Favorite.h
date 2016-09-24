//
//  Favorite.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/29/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class TBAFavorite;

NS_ASSUME_NONNULL_BEGIN

@interface Favorite : TBAManagedObject

@property (nonatomic, retain) NSString *deviceKey;
@property (nonatomic, retain) NSString *modelKey;
@property (nonatomic, retain) NSNumber *modelType;

+ (instancetype)insertFavoriteWithModelFavorite:(TBAFavorite *)modelFavorite inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Favorite *> *)insertFavoritesWithModelFavorites:(NSArray<TBAFavorite *> *)modelFavorites inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
