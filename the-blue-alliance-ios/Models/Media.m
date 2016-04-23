//
//  Media.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "Media.h"
#import "Team.h"
#import "TBAMedia.h"

@implementation Media

@dynamic foreignKey;
@dynamic imagePartial;
@dynamic mediaType;
@dynamic year;
@dynamic team;

+ (instancetype)insertMediaWithModelMedia:(TBAMedia *)modelMedia forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@ AND year == %@ AND foreignKey == %@", team, @(year), modelMedia.foreignKey];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Media *media) {
        Team *t = [context objectWithID:team.objectID];
        
        media.team = t;
        media.year = @(year);
        
        media.foreignKey = modelMedia.foreignKey;
        media.mediaType = @(modelMedia.type);
        media.imagePartial = modelMedia.details.imagePartial;
    }];
}

+ (NSArray *)insertMediasWithModelMedias:(NSArray<TBAMedia *> *)modelMedias forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMedia *media in modelMedias) {
        [arr addObject:[self insertMediaWithModelMedia:media forTeam:team andYear:year inManagedObjectContext:context]];
    }
    return arr;
}

@end
