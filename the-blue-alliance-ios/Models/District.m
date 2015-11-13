//
//  District.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "District.h"
#import "DistrictRanking.h"

@implementation District

+ (NSArray *)districtTypes {
    return @[@"Michigan", @"Mid Atlantic", @"New England", @"Pacific Northwest", @"Indiana"];
}

+ (instancetype)insertDistrictWithDistrictDict:(NSDictionary<NSString *, NSString *> *)districtDict forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"District" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@ && year == %@", districtDict[@"key"], @(year)];
    [fetchRequest setPredicate:predicate];
    
    District *district;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        district = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (District *d in existingObjs) {
            [context deleteObject:d];
        }
    }
    
    if (district == nil) {
        district = [NSEntityDescription insertNewObjectForEntityForName:@"District" inManagedObjectContext:context];
    }
    
    district.key = districtDict[@"key"];
    district.name = districtDict[@"name"];
    district.year = @(year);
    
    return district;
}

+ (NSArray *)insertDistrictsWithDistrictDicts:(NSArray<NSDictionary<NSString *, NSString *> *> *)districtDicts forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *district in districtDicts) {
        [arr addObject:[self insertDistrictWithDistrictDict:district forYear:year inManagedObjectContext:context]];
    }
    return arr;
}

@end
