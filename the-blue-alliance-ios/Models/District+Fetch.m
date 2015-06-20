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

+ (void)fetchDistrictsForYear:(NSInteger)year fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *districts, NSError *error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"District"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@", @(year)];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    NSError *error = nil;
    NSArray *districts = [context executeFetchRequest:fetchRequest error:&error];
    if (completion) {
        completion(districts, error);
    }
}

+ (void)fetchEventsForDistrict:(District *)district fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *events, NSError *error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventDistrict == %@ AND year == %@", district.name, district.year];
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

+ (void)fetchDistrictRankingsForDistrict:(District *)district fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *rankings, NSError *error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DistrictRanking"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"district == %@", district];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *rankSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    [fetchRequest setSortDescriptors:@[rankSortDescriptor]];
    
    NSError *error = nil;
    NSArray *districtRankings = [context executeFetchRequest:fetchRequest error:&error];
    if (completion) {
        completion(districtRankings, error);
    }
}

@end
