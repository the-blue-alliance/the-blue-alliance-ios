#import "_Team.h"

@interface Team : _Team {}

+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertTeamsWithModelTeams:(NSArray *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context;

@end
