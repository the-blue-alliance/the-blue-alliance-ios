//
//  Match.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

typedef NS_ENUM(NSInteger, CompLevel) {
    CompLevelQualification,
    CompLevelQuarterFinal,
    CompLevelSemiFinal,
    CompLevelFinal
};

@class Event, Team, MatchVideo;

NS_ASSUME_NONNULL_BEGIN

@interface Match : TBAManagedObject

@property (nonatomic, retain) NSNumber *blueScore;
@property (nonatomic, retain) NSNumber *compLevel;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSNumber *matchNumber;
@property (nonatomic, retain) NSNumber *redScore;
@property (nullable, nonatomic, retain) NSDictionary *scoreBreakdown;
@property (nonatomic, retain) NSNumber *setNumber;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) NSSet<MatchVideo *> *vidoes;
@property (nullable, nonatomic, retain) NSOrderedSet<Team *> *redAlliance;
@property (nullable, nonatomic, retain) NSOrderedSet<Team *> *blueAlliance;

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchesWithModelMatches:(NSArray<TBAMatch *> *)modelMatches forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)timeString;
- (NSString *)compLevelString;
- (NSString *)friendlyMatchName;

@end

NS_ASSUME_NONNULL_END
