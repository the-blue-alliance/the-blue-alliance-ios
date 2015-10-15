//
//  EventAlliance.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventAlliance : NSManagedObject

+ (instancetype)insertEventAllianceWithModelEventWebcast:(TBAEventAlliance *)modelEventAlliance forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "EventAlliance+CoreDataProperties.h"
