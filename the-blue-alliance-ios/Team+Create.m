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

+ (NSString *)groupingTextOfTeamNumber:(int)teamNumber
{
    if(teamNumber < 1000) {
        return @"1-990";
    } else {
        return [NSString stringWithFormat:@"%d's", teamNumber / 1000 * 1000];
    }
}

+ (Team *)createTeamFromTBAInfo:(NSDictionary *)info
        usingManagedObjectContext:(NSManagedObjectContext *)context
{
    // Validates the dictionary and makes it safe to pull data from
    info = [Team normalizeTeamInfoDictionary:info];
    
    
    Team *team = [NSEntityDescription insertNewObjectForEntityForName:@"Team"
                                               inManagedObjectContext:context];
    
    team.key = info[@"key"];
    team.name = info[@"name"];
    team.team_number = @([info[@"team_number"] intValue]);
    team.address = info[@"address"];
    team.nickname = info[@"nickname"];
    team.website = info[@"website"];
    team.location = info[@"location"];
    team.last_updated = @([[NSDate date] timeIntervalSince1970]);
    team.grouping_text = [Team groupingTextOfTeamNumber:[info[@"team_number"] intValue]];
    // TODO: Finish / improve importing
    
    NSLog(@"Imported team %@ into the database", info[@"key"]);
    
    return team;
}

+ (NSArray *)createTeamsFromTBAInfoArray:(NSArray *)infoArray
           usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *returnTeams = [[NSMutableArray alloc] init];
    
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
    NSMutableDictionary *exisingTeamDict = [[NSMutableDictionary alloc] init];
    for (Team *team in existingTeams) {
        [existingKeySet addObject:team.key];
        exisingTeamDict[team.key] = team;
    }
    
    
    for (NSDictionary *infoDict in infoArray) {
        if(![existingKeySet containsObject:infoDict[@"key"]]) {
            [returnTeams addObject:[Team createTeamFromTBAInfo:infoDict usingManagedObjectContext:context]];
        } else {
            [returnTeams addObject:exisingTeamDict[infoDict[@"key"]]];
        }
    }
    
    return returnTeams;
}
@end
