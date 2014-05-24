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

+ (void) executeTBAV2Request:(NSString *)request withCallback:(void(^)(id, NSError *))callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.thebluealliance.com/api/v2/%@/", request]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"tba-ios:tba-ios-app:v0.1" forHTTPHeaderField:@"X-TBA-App-Id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error || !data) {
                callback(nil, error);
            } else {
                NSError *jsonError;
                id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if(jsonError || !obj) {
                    callback(nil, jsonError);
                } else {
                    callback(obj, nil);
                }
            }
        });
    });
}

+ (void) importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context
{
    [TBAImporter executeTBAV2Request:@"events" withCallback:^(id data, NSError *error) {
        NSArray *events = data;
        if(error || !events) {
            NSLog(@"Error importing list of events: %@", error);
        } else {
            [Event createEventsFromTBAInfoArray:events usingManagedObjectContext:context];
        }
    }];
}


+ (void) importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context
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
