#import "_Media.h"

@class TBAMedia;

@interface Media : _Media {}

+ (instancetype)insertMediaWithModelMedia:(TBAMedia *)modelMedia forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMediasWithModelMedias:(NSArray *)modelMedias forTeam:(Team *)team andYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;

@end
