//
//  EventAlliance.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface EventAlliance : TBAManagedObject

@property (nonatomic, retain) NSNumber *allianceNumber;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSOrderedSet<Team *> *picks;
@property (nullable, nonatomic, retain) NSOrderedSet<Team *> *declines;

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
