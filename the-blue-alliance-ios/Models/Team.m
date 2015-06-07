//
//  Team.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Team.h"
#import "TBATeam.h"

@implementation Team

@dynamic website;
@dynamic name;
@dynamic locality;
@dynamic region;
@dynamic countryName;
@dynamic location;
@dynamic teamNumber;
@dynamic key;
@dynamic nickname;
@dynamic rookieYear;

+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Team" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelTeam.key];
    [fetchRequest setPredicate:predicate];
    
    Team *team;

    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    
    if(existingObjs.count == 1) {
        team = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (Team *t in existingObjs) {
            [context deleteObject:t];
        }
    }

    if (team == nil) {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:context];
    }

    team.website = modelTeam.website;
    team.name = modelTeam.name;
    team.locality = modelTeam.locality;
    team.region = modelTeam.region;
    team.countryName = modelTeam.countryName;
    team.location = modelTeam.location;
    team.teamNumber = modelTeam.teamNumber;
    team.key = modelTeam.key;
    team.nickname = modelTeam.nickname;
    team.rookieYear = modelTeam.rookieYear;
    
    return team;
}

+ (NSArray *)insertTeamsWithModelTeams:(NSArray *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBATeam *team in modelTeams) {
        [arr addObject:[self insertTeamWithModelTeam:team inManagedObjectContext:context]];
    }
    return arr;
}


- (NSString *)nickname {
    [self willAccessValueForKey:@"nickname"];
    NSString *nickname = [self primitiveValueForKey:@"nickname"];
    [self didAccessValueForKey:@"nickname"];
    
    NSString *trimmedNickname = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!nickname || [trimmedNickname isEqualToString:@""]) {
        nickname = [NSString stringWithFormat:@"Team %lld", self.teamNumber];
    }
    return nickname;
}

@end
