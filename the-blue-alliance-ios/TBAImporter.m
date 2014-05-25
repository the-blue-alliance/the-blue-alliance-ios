//
//  DatabaseImporter.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBAImporter.h"
#import "Event+Create.h"
#import "Team+Create.h"

#import <CHCSVParser/CHCSVParser.h>

@implementation TBAImporter

+ (id) executeTBAV2Request:(NSString *)request
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thebluealliance.com/api/v2/%@", request]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"tba-ios:tba-ios-app:v0.1" forHTTPHeaderField:@"X-TBA-App-Id"];
    
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

    int startYear = 1992;
    int endYear = (int)[NSDate date].year + 1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *downloadedEvents = [[NSMutableArray alloc] init];
        // Download the currently selected year first
        if (currentYear != 0) {
            NSArray *events = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%d", currentYear]];
            [downloadedEvents addObjectsFromArray:events];
        }
        for(int i = endYear; i >= startYear; i--) {
            if (i == currentYear)
                continue;
            NSArray *events = [TBAImporter executeTBAV2Request:[NSString stringWithFormat:@"events/%d", i]];
            [downloadedEvents addObjectsFromArray:events];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [Event createEventsFromTBAInfoArray:downloadedEvents usingManagedObjectContext:context];
        });
    });
}


+ (void)importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    // Do stupid CSV import for now
    NSURL *teamsListURL = [NSURL URLWithString:@"http://www.thebluealliance.com/api/csv/teams/all"];
    NSMutableURLRequest *teamsRequest = [NSMutableURLRequest requestWithURL:teamsListURL];
    [teamsRequest addValue:@"tba-ios:tba-ios-app:v0.1" forHTTPHeaderField:@"X-TBA-App-Id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:teamsRequest returningResponse:&response error:&error];
        
        NSString *csvString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        csvString = [csvString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *teamLines = [csvString CSVComponents];
        NSArray *keys = [teamLines firstObject];
        
        NSMutableArray *teamInfoArray = [[NSMutableArray alloc] init];
        for (int i = 1; i < teamLines.count; i++) {
            NSArray *values = teamLines[i];
            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
            if([infoDict[@"team_number"] intValue] > 0) {
                infoDict[@"key"] = [NSString stringWithFormat:@"frc%@", infoDict[@"team_number"]];
                [teamInfoArray addObject:infoDict];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [Team createTeamsFromTBAInfoArray:teamInfoArray usingManagedObjectContext:context];
        });
        
        
        
    });
}

@end
