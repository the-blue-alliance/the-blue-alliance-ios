//
//  Team+Create.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Team+Create.h"

@implementation Team (Create)

// Validates the dictionary and makes it safe to pull data from
+ (NSDictionary *)normalizeTeamInfoDictionary:(NSDictionary *)info
{
    NSMutableDictionary *normInfo = [info mutableCopy];
    
    NSSet *nullSet = [normInfo keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return obj == [NSNull null];
    }];
    [normInfo removeObjectsForKeys:[nullSet allObjects]];
    
    return normInfo;
}

+ (Team *)createTeamFromTBAInfo:(NSDictionary *)info
        usingManagedObjectContext:(NSManagedObjectContext *)context
{
    Team *team = nil;
    
    // Validates the dictionary and makes it safe to pull data from
    info = [Team normalizeTeamInfoDictionary:info];
    
    NSString *key = info[@"key"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key = %@", key];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    if (error || !matches || matches.count > 1) {
        NSLog(@"ERROR searching for existing team with key %@. %lu matches found. Error: %@", key, (unsigned long)matches.count, error);
    } else if (matches.count) {
        team = [matches firstObject];
    } else {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"Team"
                                              inManagedObjectContext:context];
        
        team.key = key;
        team.name = info[@"name"];
        team.team_number = @([info[@"team_number"] intValue]);
        team.address = info[@"address"];
        team.nickname = info[@"nickname"];
        team.website = info[@"website"];
        team.location = info[@"location"];
        team.last_updated = @([[NSDate date] timeIntervalSince1970]);
        // TODO: Finish / improve importing
        
        NSLog(@"Imported team %@ into the database", key);
    }
    
    return team;
}

+ (void) createTeamsFromTBAInfoArray:(NSArray *)infoArray
           usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *teamKeys = [[NSMutableArray alloc] init];
    for (NSDictionary *teamInfo in infoArray) {
        [teamKeys addObject:teamInfo[@"key"]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Team" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", teamKeys];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"team_number" ascending:YES]]];
    
    NSError *error = nil;
    NSArray *existingTeams = [context executeFetchRequest:fetchRequest error:&error];
    if (existingTeams == nil) {
        NSLog(@"Core Data error: handle this error... :(");
    }
    
    NSMutableSet *existingKeySet = [[NSMutableSet alloc] init];
    for (Team *team in existingTeams) {
        [existingKeySet addObject:team.key];
    }
    
    
    for (NSDictionary *infoDict in infoArray) {
        if(![existingKeySet containsObject:infoDict[@"key"]]) {
            [Team createTeamFromTBAInfo:infoDict usingManagedObjectContext:context];
        }
    }
}
@end
