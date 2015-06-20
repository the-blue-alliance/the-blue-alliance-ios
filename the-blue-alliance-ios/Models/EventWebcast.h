#import "_EventWebcast.h"

typedef NS_ENUM(NSInteger, WebcastType) {
    WebcastTypeLivestream,
    WebcastTypeMMS,
    WebcastTypeRTMP,
    WebcastTypeTwitch,
    WebcastTypeUstream,
    WebcastTypeYoutube,
    WebcastTypeIFrame,
    WebcastTypeHTML5
};

@interface EventWebcast : _EventWebcast {}

+ (instancetype)insertEventWebcastWithModelEventWebcast:(TBAEventWebcast *)modelEventWebcast forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventWebcastsWithModelEventWebcasts:(NSArray *)modelEventWebcasts forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end
