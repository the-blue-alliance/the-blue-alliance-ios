//
//  Media.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class Team, TBAMedia;

NS_ASSUME_NONNULL_BEGIN

@interface Media : TBAManagedObject

@property (nonatomic, retain) NSString *foreignKey;
@property (nullable, nonatomic, retain) NSString *imagePartial;
@property (nonatomic, retain) NSNumber *mediaType;
@property (nonatomic, retain) NSNumber *year;
@property (nonatomic, retain) Team *team;

+ (instancetype)insertMediaWithModelMedia:(TBAMedia *)modelMedia forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMediasWithModelMedias:(NSArray<TBAMedia *> *)modelMedias forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
