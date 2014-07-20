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

#define kIDHeader @"the-blue-alliance:ios:v0.1"

@implementation TBAImporter

+ (id)executeTBAV2Request:(NSString *)request
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thebluealliance.com/api/v2/%@", request]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:kIDHeader forHTTPHeaderField:@"X-TBA-App-Id"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSLog(@"Executed TBA API request: %@", request);
    
    if(error || !data) {
        NSLog(@"Handle downloading error...");
        return nil;
    } else {
        NSError *jsonError;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(jsonError || !obj) {
            NSLog(@"Handle JSON error");
            return nil;
        } else {
            return obj;
        }
    }
}

+ (void)importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSInteger currentYear = [[NSUserDefaults standardUserDefaults] integerForKey:@"EventsViewController.currentYear"];
    if(currentYear == 0) {
        currentYear = [NSDate date].year;
    }

    int startYear = 1992;
    int endYear = (int)[NSDate date].year + 1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Download the currently selected year first
        if (currentYear != 0) {
            NSArray *events = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%@", @(currentYear)]];
            
            [context performBlock:^{
                [Event createManagedObjectsFromInfoArray:events
                       checkingPrexistanceUsingUniqueKey:@"key"
                               usingManagedObjectContext:context];
            }];
        }
        
        NSMutableArray *downloadedEvents = [[NSMutableArray alloc] init];
        for(int i = endYear; i >= startYear; i--) {
            if (i == currentYear)
                continue;
            NSArray *events = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%d", i]];
            [downloadedEvents addObjectsFromArray:events];
        }
        
        [context performBlock:^{
            [Event createManagedObjectsFromInfoArray:downloadedEvents
                   checkingPrexistanceUsingUniqueKey:@"key"
                           usingManagedObjectContext:context];
        }];
    });
}


+ (void)importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    __block int page = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *downloadedTeams = [[NSMutableArray alloc] init];
        NSArray *teams = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"teams/%d", page]];

        while (teams && [teams count] > 0) {
            [downloadedTeams addObjectsFromArray:teams];
            page++;
            teams = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"teams/%d", page]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [Team createManagedObjectsFromInfoArray:downloadedTeams
                  checkingPrexistanceUsingUniqueKey:@"key"
                          usingManagedObjectContext:context];
        });
    });
}

+ (void)linkTeamsToEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *eventKey = event.key;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *teamList = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/teams", eventKey]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *teams = [Team createManagedObjectsFromInfoArray:teamList
                                   checkingPrexistanceUsingUniqueKey:@"key"
                                           usingManagedObjectContext:context];
            event.teams = [NSSet setWithArray:teams];
        });
    });
    
}

+ (void)importRankingsForEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context callback:(void (^)(NSString *rankingsString))callback;
{
    NSString *eventKey = event.key;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *rankArray = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/rankings", eventKey]];
        NSString *rankingsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:rankArray options:0 error:nil] encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            event.rankings = rankingsString;
//            [context save:nil];
            callback(rankingsString);
        });
    });
}


+ (void)importMatchesForEvent:(Event *)event
    usingManagedObjectContext:(NSManagedObjectContext *)context
                     callback:(void (^)(NSSet *matches))callback {
    
    NSString *eventKey = event.key;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *matchDicts = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"event/%@/matches", eventKey]];
        NSMutableSet *commonTeamKeys = [[NSMutableSet alloc] init];
        for (NSDictionary *match in matchDicts) {
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
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *matchesArray = [Match createManagedObjectsFromInfoArray:matchDicts
                                           checkingPrexistanceUsingUniqueKey:@"key"
                                                   usingManagedObjectContext:context
                                                                    userInfo:teamsInMatches];
            NSSet *matches = [NSSet setWithArray:matchesArray];
            
            event.matches = matches;
            
//            [context save:nil];
            callback(matches);
        });
    });
}

@end
