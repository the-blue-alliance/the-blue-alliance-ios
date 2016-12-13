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

@dynamic key;
@dynamic name;
@dynamic year;
@dynamic districtRankings;

+ (instancetype)insertDistrictWithDistrictDict:(NSDictionary<NSString *, NSString *> *)districtDict forYear:(NSNumber *)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@ && year == %@", districtDict[@"key"], year];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(District *district) {
        district.key = districtDict[@"key"];
        district.name = districtDict[@"name"];
        district.year = year;
    }];
}

+ (NSArray *)insertDistrictsWithDistrictDicts:(NSArray<NSDictionary<NSString *, NSString *> *> *)districtDicts forYear:(NSNumber *)year inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *district in districtDicts) {
        [arr addObject:[self insertDistrictWithDistrictDict:district forYear:year inManagedObjectContext:context]];
    }
    return arr;
}

@end
