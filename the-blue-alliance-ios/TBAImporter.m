//
//  DatabaseImporter.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBAImporter.h"
/*
#import "NSManagedObject+Create.h"
#import "Event.h"
#import "Team.h"
#import "Match.h"
#import "DistrictRanking.h"
#import "DistrictPoints.h"
#import "TBAApp.h"
*/

@implementation TBAImporter

/*
+ (NSArray *)importObjects:(NSArray *)objects forClass:(Class)ModelClass {
    return [self importObjects:objects withUniqueKey:@"key" forClass:ModelClass];
}

+ (NSArray *)importObjects:(NSArray *)objects withUniqueKey:(NSString *)key forClass:(Class)ModelClass {
    NSArray *objectsArray = [ModelClass createManagedObjectsFromInfoArray:objects
                                        checkingPrexistanceUsingUniqueKey:key
                                                usingManagedObjectContext:[TBAApp managedObjectContext]];
    [TBAApp saveContext];
    
    return objectsArray;
}

+ (Event *)importEvent:(NSDictionary *)event {
    return [[self importEvents:@[event]] firstObject];
}

+ (NSArray *)importEvents:(NSArray *)events {
    return [self importObjects:events withUniqueKey:@"key" forClass:[Event class]];
}

+ (Team *)importTeam:(NSDictionary *)team {
    return [[self importTeams:@[team]] firstObject];
}

+ (NSArray *)importTeams:(NSArray *)teams {
    NSMutableArray *importTeams = [teams mutableCopy];
    NSMutableArray *teamsToRemove = [[NSMutableArray alloc] init];

    for (NSDictionary *teamDict in importTeams) {
        if (![[teamDict allKeys] containsObject:@"nickname"] || !teamDict[@"nickname"] || teamDict[@"nickname"] == [NSNull null]) {
            [teamsToRemove addObject:teamDict];
        }
    }
    [importTeams removeObjectsInArray:teamsToRemove];
    
    return [self importObjects:importTeams withUniqueKey:@"key" forClass:[Team class]];
}

+ (DistrictRanking *)importDistrictRanking:(NSDictionary *)districtRanking {
    return [[self importObjects:@[districtRanking] forClass:[DistrictRanking class]] firstObject];
}

+ (DistrictPoints *)importDistrictPoints:(NSDictionary *)districtPoints {
    return [[self importObjects:@[districtPoints] forClass:[DistrictPoints class]] firstObject];
}
*/

/*
+ (void)importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSInteger currentYear = [[NSUserDefaults standardUserDefaults] integerForKey:@"EventsViewController.currentYear"];
    if (currentYear == 0) {
        currentYear = [NSDate date].year;
    }

    int startYear = 1992;
    int endYear = (int)[NSDate date].year + 1;
    
    // Download the currently selected year first
    if (currentYear != 0) {
        NSString *endpointString = NSString stringWithFormat:@"events/%@", @(currentYear)];
        
        [[TBAImporter sharedImporter] executeTBAV2Request:endpointString callback:^(id objects, NSError *error) {
            if (error) {
                NSLog(@"Error importing events!");
            }
            [context performBlock:^{
                [Event createManagedObjectsFromInfoArray:events
                       checkingPrexistanceUsingUniqueKey:@"key"
                               usingManagedObjectContext:context];
            }];
        }];
    }
    
    NSMutableArray *downloadedEvents = [[NSMutableArray alloc] init];
    for(int i = endYear; i >= startYear; i--) {
        if (i == currentYear)
            continue;
        
        [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%d", i] callback:^(id objects) {
            [context performBlock:^{
                [Event createManagedObjectsFromInfoArray:downloadedEvents
                       checkingPrexistanceUsingUniqueKey:@"key"
                               usingManagedObjectContext:context];
            }];
        }];
    }
}



+ (void)importTeamsPage:(int)page collectedTeams:(NSMutableArray *)collectedTeams usingContext:(NSManagedObjectContext *)context
{
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"teams/%d", page] callback:^(id objects) {
        if([objects count] > 0) {
            [collectedTeams addObjectsFromArray:objects];
            [self importTeamsPage:page+1 collectedTeams:collectedTeams usingContext:context];
        } else {
            [Team createManagedObjectsFromInfoArray:collectedTeams
                  checkingPrexistanceUsingUniqueKey:@"key"
                          usingManagedObjectContext:context];
        }
    }];
}

+ (void)importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    [self importTeamsPage:0 collectedTeams:[[NSMutableArray alloc] init] usingContext:context];
}

+ (void)linkTeamsToEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *eventKey = event.key;
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/teams", eventKey] callback:^(id objects) {
        if(objects) {
            NSArray *teams = [Team createManagedObjectsFromInfoArray:objects
                               checkingPrexistanceUsingUniqueKey:@"key"
                                       usingManagedObjectContext:context];
            event.teams = [NSSet setWithArray:teams];
        }
    }];
}

+ (void)linkEventsToTeam:(Team *)team forYear:(NSInteger)year usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *teamKey = team.key;
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"team/%@/%ld/events", teamKey, (long)year] callback:^(id objects) {
        if(objects) {
            NSArray *events = [Event createManagedObjectsFromInfoArray:objects
                                 checkingPrexistanceUsingUniqueKey:@"key"
                                         usingManagedObjectContext:context];
            [team addEvents:[NSSet setWithArray:events]];
        }
    }];
}

+ (void)linkMediaToTeam:(Team *)team forYear:(NSInteger)year usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *teamKey = team.key;
    
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"team/%@/%ld/media", teamKey, (long)year] callback:^(id objects) {
        
        if(objects) {
            NSMutableArray *fixedMediaList = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (NSDictionary *mediaDict in objects) {
                NSMutableDictionary *mutMediaDict = [mediaDict mutableCopy];
                mutMediaDict[@"key"] = mediaDict[@"foreign_key"];
                [fixedMediaList addObject:mutMediaDict];
            }
            NSArray *medias = [Media createManagedObjectsFromInfoArray:fixedMediaList
                                     checkingPrexistanceUsingUniqueKey:@"key"
                                             usingManagedObjectContext:context];
            [team addMedia:[NSSet setWithArray:medias]];
        }
    }];
}


+ (void)importRankingsForEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context callback:(void (^)(NSString *rankingsString))callback;
{
    NSString *eventKey = event.key;
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/rankings", eventKey] callback:^(id objects) {
        if(objects) {
            NSString *rankingsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:objects options:0 error:nil]
                                                             encoding:NSUTF8StringEncoding];
            event.rankings = rankingsString;
            callback(rankingsString);
        } else {
            callback(event.rankings);
        }
    }];
}


+ (void)importMatchesForEvent:(Event *)event
    usingManagedObjectContext:(NSManagedObjectContext *)context
                     callback:(void (^)(NSSet *matches))callback {
    
    NSString *eventKey = event.key;
    [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/matches", eventKey] callback:^(id objects) {
        NSMutableSet *commonTeamKeys = [[NSMutableSet alloc] init];
        for (NSDictionary *match in objects) {
            [commonTeamKeys addObjectsFromArray:[match valueForKeyPath:@"alliances.red.teams"]];
            [commonTeamKeys addObjectsFromArray:[match valueForKeyPath:@"alliances.blue.teams"]];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Team" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", commonTeamKeys];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *teamsInMatches = [context executeFetchRequest:fetchRequest error:&error];
        
        
        NSArray *matchesArray = [Match createManagedObjectsFromInfoArray:objects
                                       checkingPrexistanceUsingUniqueKey:@"key"
                                               usingManagedObjectContext:context
                                                                userInfo:teamsInMatches];
        NSSet *matches = [NSSet setWithArray:matchesArray];
        
        event.matches = matches;
        
        callback(matches);
        
    }];
    
}
*/

@end
