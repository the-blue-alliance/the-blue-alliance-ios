//
//  EventAlliance.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventAlliance : NSManagedObject

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "EventAlliance+CoreDataProperties.h"
