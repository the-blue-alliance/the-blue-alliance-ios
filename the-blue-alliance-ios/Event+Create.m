//
//  Event+TBA.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event+Create.h"

@implementation Event (Create)

+ (Event *) createEventFromTBAInfo:(NSDictionary *)info
         usingManagedObjectContext:(NSManagedObjectContext *)context
{
    Event *event = nil;
    
    NSString *key = info[@"key"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key = %@", key];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    if (error || !matches || matches.count > 1) {
        NSLog(@"ERROR searching for existing event with key %@. %lu matches found. Error: %@", key, (unsigned long)matches.count, error);
    } else if (matches.count) {
        event = [matches firstObject];
    } else {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                              inManagedObjectContext:context];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        
        event.key = key;
        event.name = info[@"name"];
        event.short_name = info[@"short_name"];
        event.official = info[@"official"];
        event.year = info[@"year"];
        event.location = info[@"location"];
        event.event_short = info[@"event_code"];
        event.start_date = [formatter dateFromString:info[@"start_date"]];
        event.end_date = [formatter dateFromString:info[@"end_date"]];
        event.event_type = info[@"event_type"];

        NSLog(@"Imported event %@ into the database", key);
    }

    return event;
}

+ (void) createEventsFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *info in infoArray) {
        [Event createEventFromTBAInfo:info usingManagedObjectContext:context];
    }
}

@end
