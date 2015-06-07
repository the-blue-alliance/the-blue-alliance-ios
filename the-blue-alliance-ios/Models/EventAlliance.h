//
//  EventAlliance.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface EventAlliance : NSManagedObject

@property (nonatomic, retain) id declines;
@property (nonatomic, retain) id picks;
@property (nonatomic, retain) Event *event;

+ (instancetype)insertEventAllianceWithModelEventWebcast:(TBAEventAlliance *)modelEventAlliance forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end
