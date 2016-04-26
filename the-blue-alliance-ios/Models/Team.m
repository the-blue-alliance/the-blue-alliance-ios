//
//  Team.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "Team.h"
#import "DistrictRanking.h"
#import "Event.h"
#import "EventPoints.h"
#import "EventRanking.h"
#import "Media.h"

@implementation Team

@dynamic countryName;
@dynamic key;
@dynamic locality;
@dynamic location;
@dynamic motto;
@dynamic name;
@dynamic nickname;
@dynamic region;
@dynamic rookieYear;
@dynamic teamNumber;
@dynamic website;
@dynamic yearsParticipated;
@dynamic districtRankings;
@dynamic eventPoints;
@dynamic eventRankings;
@dynamic events;
@dynamic media;
@dynamic awards;
@dynamic redMatches;
@dynamic blueMatches;

+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelTeam.key];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Team *team) {
        team.website = modelTeam.website;
        team.name = modelTeam.name;
        team.motto = modelTeam.motto;
        team.locality = modelTeam.locality;
        team.region = modelTeam.region;
        team.countryName = modelTeam.countryName;
        team.location = modelTeam.location;
        team.teamNumber = @(modelTeam.teamNumber);
        team.key = modelTeam.key;
        team.nickname = modelTeam.nickname;
        team.rookieYear = @(modelTeam.rookieYear);
    }];
}

+ (instancetype)insertStubTeamWithKey:(NSString *)teamKey inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", teamKey];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Team *team) {
        NSString *teamNumber = [teamKey substringFromIndex:3];
        
        team.key = teamKey;
        team.teamNumber = @([teamNumber integerValue]);
    }];
}

+ (NSArray *)insertTeamsWithModelTeams:(NSArray<TBATeam *> *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBATeam *team in modelTeams) {
        [arr addObject:[self insertTeamWithModelTeam:team inManagedObjectContext:context]];
    }
    return arr;
}

+ (NSArray *)insertTeamsWithModelTeams:(NSArray<TBATeam *> *)modelTeams forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context  {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBATeam *team in modelTeams) {
        Team *t = [self insertTeamWithModelTeam:team inManagedObjectContext:context];
        t.events = [t.events setByAddingObject:event];
        [arr addObject:t];
    }
    return arr;
}


- (NSString *)nickname {
    [self willAccessValueForKey:@"nickname"];
    NSString *nickname = [self primitiveValueForKey:@"nickname"];
    [self didAccessValueForKey:@"nickname"];
    
    NSString *trimmedNickname = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!nickname || [trimmedNickname isEqualToString:@""]) {
        nickname = [NSString stringWithFormat:@"Team %@", self.teamNumber];
    }
    return nickname;
}

- (NSArray *)sortedEventsForYear:(NSInteger)year {
    NSSortDescriptor *startDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    NSArray *sorted = [self.events sortedArrayUsingDescriptors:[NSArray arrayWithObject:startDateSortDescriptor]];
    
    return [sorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"year == %@", @(year)]];
}

- (NSArray *)sortedYearsParticipated {
    NSMutableArray *years = [self.yearsParticipated mutableCopy];
    
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    return [years sortedArrayUsingDescriptors:@[highestToLowest]];
}

- (void)setEvents:(NSSet<Event *> * _Nullable)events forYear:(NSNumber *)year {
    // Filter all events that are not in the year we're setting for
    NSMutableSet<Event *> *allOtherEvents = [[NSMutableSet alloc] init];
    for (Event *event in self.events) {
        if (event.year.integerValue != year.integerValue) {
            [allOtherEvents addObject:event];
        }
    }
    // Combine all not-this-year events and our new this-year events
    self.events = [allOtherEvents setByAddingObjectsFromSet:events];
}

@end
