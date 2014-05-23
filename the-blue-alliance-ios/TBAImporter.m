//
//  DatabaseImporter.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBAImporter.h"
#import "Event+Create.h"

@implementation TBAImporter

+ (void) executeTBAV2Request:(NSString *)request withCallback:(void(^)(id, NSError *))callback
{
    NSURL *eventsListURL = [NSURL URLWithString:@"http://www.thebluealliance.com/api/v2/events/"];
    NSMutableURLRequest *eventsRequest = [NSMutableURLRequest requestWithURL:eventsListURL];
    [eventsRequest addValue:@"tba-ios:tba-ios-app:v0.1" forHTTPHeaderField:@"X-TBA-App-Id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:eventsRequest returningResponse:&response error:&error];
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
            NSLog(@"ERROR: %@ parsing JSON of event list: %@", error, data);
        } else {
            [Event createEventsFromTBAInfoArray:events usingManagedObjectContext:context];
        }

    }];
    
    
    
}

@end
