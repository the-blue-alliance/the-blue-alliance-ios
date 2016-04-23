//
//  EventRanking.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "EventRanking.h"
#import "Event.h"
#import "Team.h"
#import "Team+Fetch.h"

@implementation EventRanking

@dynamic info;
@dynamic rank;
@dynamic record;
@dynamic event;
@dynamic team;

+ (instancetype)insertEventRankingWithEventRankingArray:(NSArray *)eventRankingArray withKeys:(NSArray *)keys forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    // Assume that the list of lists has rank first
    // and team # second, always
    NSUInteger teamKeyIndex = [keys indexOfObject:@"Team"];
    NSString *teamKey = [NSString stringWithFormat:@"frc%@", [eventRankingArray objectAtIndex:teamKeyIndex]];
    
    dispatch_semaphore_t teamSemaphore = dispatch_semaphore_create(0);
    __block Team *team;
    
    [Team fetchTeamForKey:teamKey fromContext:context checkUpstream:YES withCompletionBlock:^(Team *localTeam, NSError *error) {
        if (error || !localTeam) {
            dispatch_semaphore_signal(teamSemaphore);
        } else {
            team = localTeam;
            dispatch_semaphore_signal(teamSemaphore);
        }
    }];
    dispatch_semaphore_wait(teamSemaphore, DISPATCH_TIME_FOREVER);
    
    if (team == nil) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@", event, team];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventRanking *eventRanking) {
        NSUInteger rankKeyIndex = [keys indexOfObject:@"Rank"];
        NSString *rankString = [eventRankingArray objectAtIndex:rankKeyIndex];
        NSNumber *rank = @([rankString integerValue]);
        eventRanking.rank = rank;
        
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
        // Remove rank and team, since we don't need to keep them
        // Keep the rest, and we'll make that our info dictionary
        for (int i = 0; i < [keys count]; i++) {
            if (i == rankKeyIndex || i == teamKeyIndex) {
                continue;
            }
            NSString *key = [keys objectAtIndex:i];
            id value = [eventRankingArray objectAtIndex:i];
            
            [infoDictionary setObject:value forKey:key];
        }
        
        Event *e = [context objectWithID:event.objectID];
        
        eventRanking.record = [self extractRecordString:&infoDictionary];
        eventRanking.info = infoDictionary;
        eventRanking.event = e;
        eventRanking.team = team;
    }];
}

+ (NSArray *)insertEventRankingsWithEventRankings:(NSArray *)eventRankings forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *rankingKeys;
    for (NSArray *eventRanking in eventRankings) {
        if (!rankingKeys) {
            rankingKeys = eventRanking;
        } else {
            [arr addObject:[self insertEventRankingWithEventRankingArray:eventRanking withKeys:rankingKeys forEvent:event inManagedObjectContext:context]];
        }
    }
    return arr;
}

+ (NSString *)extractRecordString:(NSDictionary **)infoDictionary {
    NSString *winsKey, *lossesKey, *tiesKey, *recordKey;
    NSString *wins, *losses, *ties, *record;
    for (NSString *key in ((NSDictionary *)*infoDictionary).allKeys) {
        if ([[key lowercaseString] containsString:@"record"]) {
            recordKey = key;
            record = [*infoDictionary objectForKey:key];
        } else if ([key caseInsensitiveCompare:@"wins"] == NSOrderedSame) {
            winsKey = key;
            wins = [*infoDictionary objectForKey:key];
        } else if ([key caseInsensitiveCompare:@"losses"] == NSOrderedSame) {
            lossesKey = key;
            losses = [*infoDictionary objectForKey:key];
        } else if ([key caseInsensitiveCompare:@"ties"] == NSOrderedSame) {
            tiesKey = key;
            ties = [*infoDictionary objectForKey:key];
        }
    }
    
    NSString *recordString;
    NSMutableDictionary *mutableInfoDictionary = [*infoDictionary mutableCopy];
    if (record) {
        recordString = [NSString stringWithFormat:@"(%@)", [*infoDictionary objectForKey:recordKey]];
        
        [mutableInfoDictionary removeObjectForKey:recordKey];
    } else if (wins && losses && ties) {
        recordString = [NSString stringWithFormat:@"(%@-%@-%@)", [*infoDictionary objectForKey:winsKey], [*infoDictionary objectForKey:lossesKey], [*infoDictionary objectForKey:tiesKey]];
        
        [mutableInfoDictionary removeObjectForKey:winsKey];
        [mutableInfoDictionary removeObjectForKey:lossesKey];
        [mutableInfoDictionary removeObjectForKey:tiesKey];
    }
    *infoDictionary = [NSDictionary dictionaryWithDictionary:mutableInfoDictionary];
    
    return recordString;
}

- (NSString *)infoString {
    NSMutableString *infoString = [[NSMutableString alloc] init];
    NSDictionary *infoDictionary = (NSDictionary *)self.info;
    
    NSEnumerator *infoEnumerator = [infoDictionary.allKeys objectEnumerator];
    NSString *key = [infoEnumerator nextObject];
    while (key) {
        id value = [infoDictionary objectForKey:key];
        NSString *valueString;
        if ([value isKindOfClass:[NSString class]]) {
            valueString = [@([value integerValue]) stringValue];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            valueString = [@([value integerValue]) stringValue];
        }
        
        NSString *infoKey = key;
        if (infoKey.length <= 3) {
            infoKey = [infoKey uppercaseString];
        } else {
            infoKey = [infoKey capitalizedString];
        }
        [infoString appendString:[NSString stringWithFormat:@"%@: %@", infoKey, valueString]];
        
        key = [infoEnumerator nextObject];
        if (key) {
            [infoString appendString:@", "];
        }
    }
    
    return infoString;
}

@end
