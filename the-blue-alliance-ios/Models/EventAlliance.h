#import "_EventAlliance.h"

@interface EventAlliance : _EventAlliance {}

+ (instancetype)insertEventAllianceWithModelEventWebcast:(TBAEventAlliance *)modelEventAlliance forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end
