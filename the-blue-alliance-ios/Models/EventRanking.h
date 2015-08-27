#import "_EventRanking.h"

@interface EventRanking : _EventRanking {}

+ (instancetype)insertEventRankingWithEventRankingArray:(NSArray *)eventRankingArray withKeys:(NSArray *)keys forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventRankingsWithEventRankings:(NSArray *)eventRankings forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
- (NSString *)infoString;

@end
