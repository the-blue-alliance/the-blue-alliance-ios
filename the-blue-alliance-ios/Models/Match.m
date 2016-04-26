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
@dynamic vidoes;

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
        
        match.vidoes = [NSSet setWithArray:[MatchVideo insertMatchVidoesWithModelMatchVidoes:modelMatch.videos forMatch:match inManagedObjectContext:context]];
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
    } else if ([compLevelString isEqualToString:@"ef"] || [compLevelString isEqualToString:@"qf"]) {
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
    NSString *compLevelString;
    switch (self.compLevel.integerValue) {
        case CompLevelQualification:
            compLevelString = @"Quals";
            break;
        case CompLevelQuarterFinal:
            compLevelString = @"Quarters";
            break;
        case CompLevelSemiFinal:
            compLevelString = @"Semis";
            break;
        case CompLevelFinal:
            compLevelString = @"Finals";
            break;
        default:
            compLevelString = @"";
            break;
    }
    return compLevelString;
}

- (NSString *)friendlyMatchName {
    NSString *matchName = [self compLevelString];
    switch (self.compLevel.integerValue) {
        case CompLevelQualification:
            matchName = [NSString stringWithFormat:@"%@ %@", matchName, self.matchNumber.stringValue];
            break;
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
