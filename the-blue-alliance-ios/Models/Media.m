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

+ (instancetype)insertMediaWithModelMedia:(TBAMedia *)modelMedia forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@ AND year == %@ AND foreignKey == %@", team, @(year), modelMedia.foreignKey];
    [fetchRequest setPredicate:predicate];
    
    Media *media;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    
    if(existingObjs.count == 1) {
        media = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        for (Media *m in existingObjs) {
            [context deleteObject:m];
        }
    }
    
    if (media == nil) {
        media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
    }
    
    media.team = team;
    media.year = @(year);
    
    media.foreignKey = modelMedia.foreignKey;
    media.mediaType = @(modelMedia.type);
    media.imagePartial = modelMedia.details.imagePartial;
    
    return media;
}

+ (NSArray *)insertMediasWithModelMedias:(NSArray<TBAMedia *> *)modelMedias forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMedia *media in modelMedias) {
        [arr addObject:[self insertMediaWithModelMedia:media forTeam:team andYear:year inManagedObjectContext:context]];
    }
    return arr;
}

@end
