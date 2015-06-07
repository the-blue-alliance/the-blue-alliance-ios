//
//  EventPoints.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Team, DistrictRanking;

@interface EventPoints : NSManagedObject

@property (nonatomic) int32_t alliancePoints;
@property (nonatomic) int32_t awardPoints;
@property (nonatomic) int32_t elimPoints;
@property (nonatomic) BOOL districtCMP;
@property (nonatomic) int32_t total;
@property (nonatomic) int32_t qualPoints;
@property (nonatomic, retain) DistrictRanking *districtRanking;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Team *team;

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context;

@end
