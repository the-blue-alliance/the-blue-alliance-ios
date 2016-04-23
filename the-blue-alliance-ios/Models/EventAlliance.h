//
//  EventAlliance.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventAlliance : TBAManagedObject

@property (nullable, nonatomic, retain) NSArray<NSString *> *declines;
@property (nonatomic, retain) NSArray<NSString *> *picks;
@property (nonatomic, retain) NSNumber *allianceNumber;
@property (nonatomic, retain) Event *event;

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
