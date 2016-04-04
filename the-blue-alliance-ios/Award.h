//
//  Award.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBAAward.h"

@class AwardRecipient, Event;

NS_ASSUME_NONNULL_BEGIN

@interface Award : NSManagedObject

+ (instancetype)insertAwardWithModelAward:(TBAAward *)modelAward forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Award *> *)insertAwardsWithModelAwards:(NSArray<TBAAward *> *)modelAwards forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Award+CoreDataProperties.h"
