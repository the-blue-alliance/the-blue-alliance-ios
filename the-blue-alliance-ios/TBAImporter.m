//
//  DatabaseImporter.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBAImporter.h"
#import "NSManagedObject+Create.h"
#import "Team+Fetch.h"
#import "Media.h"
#import <AFNetworking/AFNetworking.h>

#define kIDHeader @"the-blue-alliance:ios:v0.1"

@implementation TBAImporter

+ (NSString *)lastModifiedForURL:(NSURL *)url
{
    NSString *urlString = @"LAST_MODIFIED:";
    urlString = [urlString stringByAppendingString:[url description]];
    return [[NSUserDefaults standardUserDefaults] stringForKey:urlString];
}

+ (void)setLastModified:(NSString *)lastModified forURL:(NSURL *)url
{
    NSString *urlString = @"LAST_MODIFIED:";
    urlString = [urlString stringByAppendingString:[url description]];
    [[NSUserDefaults standardUserDefaults] setObject:lastModified forKey:urlString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)executeTBAV2Request:(NSString *)request callback:(void (^)(id objects))callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thebluealliance.com/api/v2/%@", request]];
    NSString *ifModifiedSince = [self lastModifiedForURL:url];
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = manager.responseSerializer = [AFJSONResponseSerializer serializer];;
    [manager.requestSerializer setValue:kIDHeader forHTTPHeaderField:@"X-TBA-App-Id"];
    if(ifModifiedSince) {
        [manager.requestSerializer setValue:ifModifiedSince forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    [manager GET:[url description] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *lastMod = [operation.response allHeaderFields][@"Last-Modified"];
        [self setLastModified:lastMod forURL:url];
        NSLog(@"URL: %@\nIf: %@\nModified: %@\n\n", url, ifModifiedSince, lastMod);
        
        if(callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(responseObject);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *lastMod = [operation.response allHeaderFields][@"Last-Modified"];
        if(operation.response.statusCode == 304) {
            NSLog(@"URL: %@\nIf: %@\nModified: %@\n\n", url, ifModifiedSince, lastMod);
            
            NSLog(@"Not modified!");
        } else {
            NSLog(@"Download error: %@", error);
        }
        
        if(callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
        }
    }];
}

+ (void)importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSInteger currentYear = [[NSUserDefaults standardUserDefaults] integerForKey:@"EventsViewController.currentYear"];
    if(currentYear == 0) {
        currentYear = [NSDate date].year;
    }

    int startYear = 1992;
    int endYear = (int)[NSDate date].year + 1;
    
    
    // Download the currently selected year first
    if (currentYear != 0) {
        [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%@", @(currentYear)] callback:^(id events) {
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

@end
