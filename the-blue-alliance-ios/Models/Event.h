#import "_Event.h"

@class OrderedDictionary;

typedef NS_ENUM(NSInteger, EventType) {
    EventTypeRegional = 0,
    EventTypeDistrict = 1,
    EventTypeDistrictCMP = 2,
    EventTypeCMPDivision = 3,
    EventTypeCMPFinals = 4,
    EventTypeOffseason = 99,
    EventTypePreseason = 100,
    EventTypeUnlabeled = -1
};

@interface Event : _Event {}

- (NSString *)friendlyNameWithYear:(BOOL)withYear;
- (NSString *)dateString;

+ (OrderedDictionary *)groupEventsByWeek:(NSArray *)events andGroupByType:(BOOL)groupByType;

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventsWithModelEvents:(NSArray *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context;

@end
