//
//  Event+Create.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event+Create.h"

@implementation Event (Create)

// Validates the dictionary and makes it safe to pull data from 
+ (NSDictionary *)normalizeEventInfoDictionary:(NSDictionary *)info
{
    NSMutableDictionary *normInfo = [info mutableCopy];
    
    NSSet *nullSet = [normInfo keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return obj == [NSNull null];
    }];
    [normInfo removeObjectsForKeys:[nullSet allObjects]];
    
    return normInfo;
}

+ (Event *)createEventFromTBAInfo:(NSDictionary *)info
         usingManagedObjectContext:(NSManagedObjectContext *)context
{
    // Validates the dictionary and makes it safe to pull data from
    info = [Event normalizeEventInfoDictionary:info];

    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                 inManagedObjectContext:context];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    event.key = info[@"key"];
    event.name = info[@"name"];
    event.short_name = info[@"short_name"];
    event.official = info[@"official"];
    event.year = info[@"year"];
    event.location = info[@"location"];
    event.event_short = info[@"event_code"];
    event.start_date = [formatter dateFromString:info[@"start_date"]];
    event.end_date = [formatter dateFromString:info[@"end_date"]];
    event.event_type = info[@"event_type"];
    event.last_updated = @([[NSDate date] timeIntervalSince1970]);
    // TODO: Finish / improve importing
    
    NSLog(@"Imported event %@ into the database", info[@"key"]);

    return event;
}

+ (void)createEventsFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *downloadedKeys = [[NSMutableArray alloc] init];
    for (NSDictionary *eventInfo in infoArray) {
        [downloadedKeys addObject:eventInfo[@"key"]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", downloadedKeys];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingEvents = [context executeFetchRequest:fetchRequest error:&error];
    if (existingEvents == nil) {
        NSLog(@"Core Data error: handle this error... :(");
    }
    
    NSMutableSet *existingKeySet = [[NSMutableSet alloc] init];
    for (Event *event in existingEvents) {
        [existingKeySet addObject:event.key];
    }
    
    
    for (NSDictionary *eventDict in infoArray) {
        if(![existingKeySet containsObject:eventDict[@"key"]]) {
            [Event createEventFromTBAInfo:eventDict usingManagedObjectContext:context];
        }
    }
}

@end
