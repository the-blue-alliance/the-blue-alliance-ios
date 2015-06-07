//
//  District.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface District : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * key;
@property (nonatomic) int64_t year;
@property (nonatomic, retain) NSSet *events;

+ (NSArray *)districtTypes;

+ (instancetype)insertDistrictWithDistrictDict:(NSDictionary *)districtDict forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictsWithDistrictDicts:(NSArray *)districtDicts forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;

@end
