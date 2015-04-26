#import "_Event.h"
#import "NSManagedObject+Create.h"

/** The constants for events
 *  https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py#L2
 */
typedef NS_ENUM(NSInteger, TBAEventType) {
    TBAEventTypeRegional = 0,
    TBAEventTypeDistrict = 1,
    TBAEventTypeDistrictCMP = 2,
    TBAEventTypeCMPDivision = 3,
    TBAEventTypeCMPFinals = 4,
    TBAEventTypeOffseason = 99,
    TBAEventTypePreseason = 100,
    TBAEventTypeUnlabeled = -1
};

@interface Event : _Event <NSManagedObjectCreatable>

/**
 *   The unique key for the event, e.g. "2014casb"
 */
@property (nonatomic, strong) NSString *key;

- (NSString *)friendlyNameWithYear:(BOOL)withYear;

+ (NSArray *)eventTypes;
+ (NSString *)nameForEventType:(TBAEventType)type;

@end
