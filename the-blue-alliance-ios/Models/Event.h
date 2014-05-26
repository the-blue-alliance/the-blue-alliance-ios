#import "_Event.h"

/** The constants for events
 *  https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py#L2
 */
typedef enum EventType : NSInteger {
    REGIONAL = 0,
    DISTRICT = 1,
    DISTRICT_CMP = 2,
    CMP_DIVISION = 3,
    CMP_FINALS = 4,
    OFFSEASON = 99,
    PRESEASON = 100,
    UNLABLED = -1
} EventType;

/** `Event` is a data model for an event
 *  http://www.thebluealliance.com/apidocs#event-model
 */
@interface Event : _Event {}
// Custom logic goes here.
@end
