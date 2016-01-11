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

@implementation Match

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Match" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelMatch.key];
    [fetchRequest setPredicate:predicate];
    
    Match *match;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        match = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (Match *m in existingObjs) {
            [context deleteObject:m];
        }
    }
    
    if (match == nil) {
        match = [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:context];
    }
    
    match.key = modelMatch.key;
    match.compLevel = @([self compLevelForString:modelMatch.compLevel]);
    match.setNumber = @(modelMatch.setNumber);
    match.matchNumber = @(modelMatch.matchNumber);
    match.scoreBreakdown = modelMatch.scoreBreakdown;
    match.time = modelMatch.time;
    match.event = event;
    
    match.redAlliance = modelMatch.redAlliance.teams;
    match.redScore = @(modelMatch.redAlliance.score);
    
    match.blueAlliance = modelMatch.blueAlliance.teams;
    match.blueScore = @(modelMatch.blueAlliance.score);
    
    match.vidoes = [NSSet setWithArray:[MatchVideo insertMatchVidoesWithModelMatchVidoes:modelMatch.videos inManagedObjectContext:context]];
    
    return match;
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
