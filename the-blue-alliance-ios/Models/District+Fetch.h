//
//  District+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District.h"

@interface District (Fetch)

// Fetch locally
+ (void)fetchDistrictsForYear:(NSInteger)year fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *districts, NSError *error))completion;
+ (void)fetchEventsForDistrict:(District *)district fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *events, NSError *error))completion;
+ (void)fetchDistrictRankingsForDistrict:(District *)district fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *rankings, NSError *error))completion;

@end
