//
//  District+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District+Fetch.h"
#import "Event.h"

@implementation District (Fetch)

#pragma mark - Local

+ (void)fetchEventsForDistrict:(nonnull District *)district fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray *_Nullable events, NSError * _Nullable error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventDistrictString == %@ AND year == %@", district.name, district.year];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *startDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[startDateSortDescriptor, nameSortDescriptor]];
    
    NSError *error = nil;
    NSArray *districtEvents = [context executeFetchRequest:fetchRequest error:&error];
    if (completion) {
        completion(districtEvents, error);
    }
}

@end
