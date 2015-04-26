//
//  District+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District+Fetch.h"
#import <CoreData/CoreData.h>

@implementation District (Fetch)

+ (NSArray *)fetchDistrictsForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"event_district" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND (NOT event_district = 0)", @(year)];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *districts = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching teams: %@", error.localizedDescription);
        return nil;
    }
    return districts;
}

@end
