//
//  Match.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Match.h"
#import "Event.h"
#import "Media.h"
#import "Team.h"
#import "Team+Fetch.h"


@implementation Match

- (void) configureSelfForInfo:(NSDictionary *)info
    usingManagedObjectContext:(NSManagedObjectContext *)context
                     withUserInfo:(id)userInfo
{
    self.key = info[@"key"];
    self.comp_level = info[@"comp_level"];
    self.set_number = info[@"set_number"];
    self.match_number = info[@"match_number"];
    self.time_string = info[@"time_string"];
    
    self.blueScore = [info valueForKeyPath:@"alliances.blue.score"];
    self.redScore = [info valueForKeyPath:@"alliances.red.score"];
    
    NSArray *blueTeamKeys = [info valueForKeyPath:@"alliances.blue.teams"];
    NSArray *redTeamKeys = [info valueForKeyPath:@"alliances.red.teams"];
    
    
    NSArray *blueTeams = [userInfo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ contains key", blueTeamKeys]];
    NSArray *redTeams = [userInfo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ contains key", redTeamKeys]];

    NSOrderedSet *blueSet = [[NSOrderedSet alloc] initWithArray:blueTeams];
    NSOrderedSet *redSet = [[NSOrderedSet alloc] initWithArray:redTeams];

    self.blueAlliance = blueSet;
    self.redAlliance = redSet;
    
    // Create media for a match:
    self.media = [NSSet setWithArray:[Media createManagedObjectsFromInfoArray:info[@"videos"] checkingPrexistanceUsingUniqueKey:@"key" usingManagedObjectContext:context]];
}

- (NSString *)friendlyMatchName {
    NSString *friendlyCompLevel = [self.comp_level.uppercaseString stringByReplacingOccurrencesOfString:@"QM" withString:@"Q"];
    if([friendlyCompLevel isEqualToString:@"Q"]) {
        return [NSString stringWithFormat:@"%@%d", friendlyCompLevel, self.match_numberValue];
    }
    return [NSString stringWithFormat:@"%@%d-%d", friendlyCompLevel, self.set_numberValue, self.match_numberValue];
}

@end
