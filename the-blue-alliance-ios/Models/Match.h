//
//  Match.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, CompLevel) {
    CompLevelQualification,
    CompLevelQuarterFinal,
    CompLevelSemiFinal,
    CompLevelFinal
};

@class Event, MatchVideo;

NS_ASSUME_NONNULL_BEGIN

@interface Match : NSManagedObject

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchesWithModelMatches:(NSArray<TBAMatch *> *)modelMatches forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)timeString;
- (NSString *)compLevelString;
- (NSString *)friendlyMatchName;

@end

NS_ASSUME_NONNULL_END

#import "Match+CoreDataProperties.h"
