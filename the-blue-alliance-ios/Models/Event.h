#import "_Event.h"

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

/** `Event` is a data model for an event
 *  http://www.thebluealliance.com/apidocs#event-model
 */
@interface Event : _Event

/**
 *   The unique key for the event, e.g. "2014casb"
 */
@property (nonatomic, strong) NSString* key;

/** 
 *  A name that includes the short_name and the year and type.  Ex: 2014 Palmetto Regional
 */
@property (nonatomic, readonly) NSString *friendlyName;

@end
