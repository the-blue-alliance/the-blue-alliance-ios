//
//  EventPoints.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class DistrictRanking, Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface EventPoints : TBAManagedObject

@property (nonatomic, retain) NSNumber *alliancePoints;
@property (nonatomic, retain) NSNumber *awardPoints;
@property (nonatomic, retain) NSNumber *elimPoints;
@property (nonatomic, retain) NSNumber *qualPoints;
@property (nonatomic, retain) NSNumber *total;
@property (nullable, nonatomic, retain) DistrictRanking *districtRanking;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Team *team;

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary<NSString *, NSNumber *> *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
