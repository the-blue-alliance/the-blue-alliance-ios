//
//  EventStat.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

typedef NS_ENUM(NSInteger, StatType) {
    StatTypeOPR,
    StatTypeCCWM,
    StatTypeDPR
};

@class Event, Team;

@interface EventTeamStat : TBAManagedObject

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, retain) NSNumber *statType;
@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Team *team;

+ (instancetype)insertEventTeamStat:(NSNumber *)score ofType:(StatType)statType forTeam:(Team *)team atEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventTeamStats:(NSDictionary<NSString *, NSNumber *> *)eventTeamStats ofType:(StatType)statType forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

