//
//  Match.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "Match.h"
#import "Event.h"
#import "MatchVideo.h"
#import "Team+Fetch.h"

@implementation Match

@dynamic blueAlliance;
@dynamic blueScore;
@dynamic compLevel;
@dynamic key;
@dynamic matchNumber;
@dynamic redAlliance;
@dynamic redScore;
@dynamic scoreBreakdown;
@dynamic setNumber;
@dynamic time;
@dynamic event;
@dynamic videos;

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelMatch.key];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Match *match) {
        match.key = modelMatch.key;
        match.compLevel = @([self compLevelForString:modelMatch.compLevel]);
        match.setNumber = @(modelMatch.setNumber);
        match.matchNumber = @(modelMatch.matchNumber);
        match.scoreBreakdown = modelMatch.scoreBreakdown;
        match.time = modelMatch.time;
        match.event = event;
    
        NSMutableOrderedSet<Team *> *redAlliance = [[NSMutableOrderedSet alloc] init];
        for (NSString *teamKey in modelMatch.redAlliance.teams) {
            Team *team = [Team insertStubTeamWithKey:teamKey inManagedObjectContext:context];
            [redAlliance addObject:team];
        }
        match.redAlliance = redAlliance;
        match.redScore = @(modelMatch.redAlliance.score);
        
        NSMutableOrderedSet<Team *> *blueAlliance = [[NSMutableOrderedSet alloc] init];
        for (NSString *teamKey in modelMatch.blueAlliance.teams) {
            Team *team = [Team insertStubTeamWithKey:teamKey inManagedObjectContext:context];
            [blueAlliance addObject:team];
        }
        match.blueAlliance = blueAlliance;
        match.blueScore = @(modelMatch.blueAlliance.score);
        
        match.videos = [NSSet setWithArray:[MatchVideo insertMatchVideosWithModelMatchVideos:modelMatch.videos forMatch:match inManagedObjectContext:context]];
    }];
}

+ (instancetype)insertStubMatchWithKey:(NSString *)matchKey inManagedObjectContext:(NSManagedObjectContext *)context {
    // Need to insert a stub event as well
    NSString *eventKey = [matchKey componentsSeparatedByString:@"_"].firstObject;
    if (!eventKey) {
        return nil;
    }
    Event *event = [Event insertStubEventWithKey:eventKey inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", matchKey];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Match *match) {
        match.key = matchKey;
        match.event = event;
    }];
}

+ (NSArray *)insertMatchesWithModelMatches:(NSArray<TBAMatch *> *)modelMatches forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMatch *match in modelMatches) {
        [arr addObject:[self insertMatchWithModelMatch:match forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

+ (CompLevel)compLevelForString:(NSString *)compLevelString {
    CompLevel compLevel;
    if ([compLevelString isEqualToString:@"qm"]) {
        compLevel = CompLevelQualification;
    } else if ([compLevelString isEqualToString:@"ef"]) {
        compLevel = CompLevelOctoFinal;
    } else if ([compLevelString isEqualToString:@"qf"]) {
        compLevel = CompLevelQuarterFinal;
    } else if ([compLevelString isEqualToString:@"sf"]) {
        compLevel = CompLevelSemiFinal;
    } else if ([compLevelString isEqualToString:@"f"]) {
        compLevel = CompLevelFinal;
    }
    return compLevel;
}

- (NSString *)timeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE h:mm a"];

    return [dateFormatter stringFromDate:self.time];
}

- (NSString *)compLevelString {
    NSString *compLevelString = @"";
    switch (self.compLevel.integerValue) {
        case CompLevelQualification:
            compLevelString = @"Qualification";
            break;
        case CompLevelOctoFinal:
            compLevelString = @"Octofinal";
            break;
        case CompLevelQuarterFinal:
            compLevelString = @"Quarterfinal";
            break;
        case CompLevelSemiFinal:
            compLevelString = @"Semifinal";
            break;
        case CompLevelFinal:
            compLevelString = @"Finals";
            break;

        default:
            break;
    }
    return compLevelString;
}

- (NSString *)shortCompLevelString {
    NSString *compLevelString = @"";
    switch (self.compLevel.integerValue) {
        case CompLevelQualification:
            compLevelString = @"Qual";
            break;
        case CompLevelOctoFinal:
            compLevelString = @"Octofinal";
            break;
        case CompLevelQuarterFinal:
            compLevelString = @"Quarter";
            break;
        case CompLevelSemiFinal:
            compLevelString = @"Semi";
            break;
        case CompLevelFinal:
            compLevelString = @"Final";
            break;
            
        default:
            break;
    }
    return compLevelString;
}

- (NSString *)friendlyMatchName {
    NSString *matchName = [self shortCompLevelString];
    switch (self.compLevel.integerValue) {
        case CompLevelQualification:
            matchName = [NSString stringWithFormat:@"%@ %@", matchName, self.matchNumber.stringValue];
            break;
        case CompLevelOctoFinal:
        case CompLevelQuarterFinal:
        case CompLevelSemiFinal:
        case CompLevelFinal:
            matchName = [NSString stringWithFormat:@"%@ %@-%@", matchName, self.setNumber.stringValue, self.matchNumber.stringValue];
            break;
        default:
            break;
    }
    return matchName;
}

@end
