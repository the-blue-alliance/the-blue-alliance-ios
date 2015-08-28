#import "_Match.h"

typedef NS_ENUM(NSInteger, CompLevel) {
    CompLevelQualification,
    CompLevelQuarterFinal,
    CompLevelSemiFinal,
    CompLevelFinal
};

@interface Match : _Match {}

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchesWithModelMatches:(NSArray *)modelMatches forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end
