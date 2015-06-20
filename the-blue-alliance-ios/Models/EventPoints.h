#import "_EventPoints.h"

@interface EventPoints : _EventPoints {}

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context;

@end
