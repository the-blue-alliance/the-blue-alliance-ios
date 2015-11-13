//
//  District.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DistrictRanking;

NS_ASSUME_NONNULL_BEGIN

@interface District : NSManagedObject

+ (NSArray *)districtTypes;

+ (instancetype)insertDistrictWithDistrictDict:(NSDictionary<NSString *, NSString *> *)districtDict forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictsWithDistrictDicts:(NSArray<NSDictionary<NSString *, NSString *> *> *)districtDicts forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "District+CoreDataProperties.h"
