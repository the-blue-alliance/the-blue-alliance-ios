//
//  Match+Create.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Match+Create.h"
#import "Team+Fetch.h"

@implementation Match (Create)

// Validates the dictionary and makes it safe to pull data from 
+ (NSDictionary *)normalizeMatchInfoDictionary:(NSDictionary *)info
{
    NSMutableDictionary *normInfo = [info mutableCopy];
    
    NSSet *nullSet = [normInfo keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return obj == [NSNull null];
    }];
    [normInfo removeObjectsForKeys:[nullSet allObjects]];
    
    return normInfo;
}

+ (Match *)createMatchFromTBAInfo:(NSDictionary *)info
        usingManagedObjectContext:(NSManagedObjectContext *)context
{
    // Validates the dictionary and makes it safe to pull data from
    info = [Match normalizeMatchInfoDictionary:info];

    Match *match = [NSEntityDescription insertNewObjectForEntityForName:@"Match"
                                                 inManagedObjectContext:context];
    
    match.key = info[@"key"];
    match.comp_level = info[@"comp_level"];
    match.set_number = info[@"set_number"];
    match.match_number = info[@"match_number"];
    match.time_string = info[@"time_string"];
    
    match.blueScore = [info valueForKeyPath:@"alliances.blue.score"];
    match.redScore = [info valueForKeyPath:@"alliances.red.score"];

    NSArray *blueTeamKeys = [info valueForKeyPath:@"alliances.blue.teams"];
    NSArray *redTeamKeys = [info valueForKeyPath:@"alliances.red.teams"];
    
    NSArray *blueTeams = [Team fetchTeamsForKeys:blueTeamKeys fromContext:context];
    NSArray *redTeams = [Team fetchTeamsForKeys:redTeamKeys fromContext:context];
    match.blueAlliance = [[NSOrderedSet alloc] initWithArray:blueTeams];
    match.redAlliance = [[NSOrderedSet alloc] initWithArray:redTeams];
    
    
    // TODO: Import media!

    NSLog(@"Imported match %@ into the database", info[@"key"]);

    return match;
}

+ (NSSet *)createMatchesFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *downloadedKeys = [[NSMutableArray alloc] init];
    for (NSDictionary *matchInfo in infoArray) {
        [downloadedKeys addObject:matchInfo[@"key"]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Match" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", downloadedKeys];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingMatches = [context executeFetchRequest:fetchRequest error:&error];
    if (existingMatches == nil) {
        NSLog(@"Core Data error: handle this error... :(");
    }
    
    NSMutableSet *existingKeySet = [[NSMutableSet alloc] init];
    NSMutableDictionary *existingMatchDict = [[NSMutableDictionary alloc] init];
    for (Match *match in existingMatches) {
        [existingKeySet addObject:match.key];
        existingMatchDict[match.key] = match;
    }
    
    
    NSMutableSet *returnMatches = [[NSMutableSet alloc] init];
    for (NSDictionary *matchDict in infoArray) {
        if(![existingKeySet containsObject:matchDict[@"key"]]) {
            Match *match = [Match createMatchFromTBAInfo:matchDict usingManagedObjectContext:context];
            [returnMatches addObject:match];
        } else {
            Match *match = existingMatchDict[matchDict[@"key"]];
            [returnMatches addObject:match];
        }
    }
    
    return returnMatches;
}

@end
