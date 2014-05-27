#import "Event.h"


@interface Event ()

// Private interface goes here.

@end


@implementation Event
@dynamic key;

- (NSString *)friendlyName
{
    NSString *withYear = [NSString stringWithFormat:@"%@ %@", self.year, self.short_name];
    
    NSString *typeSuffix = @"";
    switch (self.event_typeValue) {
        case TBAEventTypeRegional:
            typeSuffix = @"Regional";
            break;
        case TBAEventTypeDistrict:
            typeSuffix = @"District";
            break;
        case TBAEventTypeDistrictCMP:
            typeSuffix = @"District CMP";
            break;
        case TBAEventTypeCMPDivision:
            typeSuffix = @"Division";
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@", withYear, typeSuffix];
}

@end
