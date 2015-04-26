#import "Event.h"
#import "Media.h"
#import <MapKit/MapKit.h>

@implementation Event
@dynamic key;

- (NSString *)friendlyNameWithYear:(BOOL)withYear {
    NSString *nameString;
    if (withYear) {
        nameString = [NSString stringWithFormat:@"%@ %@", [self.year stringValue], self.short_name ? self.short_name : self.name];
    } else {
        nameString = [NSString stringWithFormat:@"%@", self.short_name ? self.short_name : self.name];
    }
    
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
    
    return [NSString stringWithFormat:@"%@ %@", nameString, typeSuffix];
}

- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context
                withUserInfo:(id)userInfo
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.year = [info[@"year"] integerValue];
    NSDate *defaultDate = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] dateFromComponents:comp];
    
    self.key = info[@"key"];
    self.name = info[@"name"];
    self.short_name = info[@"short_name"];
    self.official = info[@"official"];
    self.year = info[@"year"];
    self.location = info[@"location"];
    self.venue = info[@"venue_address"];
    self.event_short = info[@"event_code"];
    self.start_date = [formatter dateFromString:info[@"start_date"]] ? [formatter dateFromString:info[@"start_date"]] : defaultDate;
    self.end_date = [formatter dateFromString:info[@"end_date"]];
    self.event_type = info[@"event_type"];
    
    self.event_district = info[@"event_district"];
    self.website = info[@"website"];
    self.last_updated = @([[NSDate date] timeIntervalSince1970]);
    
    if(!self.start_date) {
        NSLog(@"Event inserted without a start date... INVALID!");
        [NSException raise:@"start_date is invalid" format:@"start_date of %@ is invalid for the event key %@", info[@"start_date"], info[@"key"]];
    }
    
    NSArray *webcastServerInfo = info[@"webcast"];
    NSMutableArray *webcastInfo = [[NSMutableArray alloc] initWithCapacity:webcastServerInfo.count];
    for (NSDictionary *webcast in webcastServerInfo) {
        NSMutableDictionary *mutWebcast = [webcast mutableCopy];
        mutWebcast[@"key"] = [NSString stringWithFormat:@"%@.%@", webcast[@"type"], webcast[@"channel"]];
        [webcastInfo addObject:mutWebcast];
    }
    NSArray *webcasts = [Media createManagedObjectsFromInfoArray:webcastInfo
                                    checkingPrexistanceUsingUniqueKey:@"key"
                                            usingManagedObjectContext:context];
    self.media = [NSSet setWithArray:webcasts];

    // TODO: Finish / improve importing
}

- (NSString *)title
{
    return self.short_name ? self.short_name : (self.name ? self.name : @"No Event Name");
}

- (NSString *)subtitle
{
    return self.venue ? self.venue : (self.location ? self.location : @"No Event Location");
}


+ (NSArray *)eventTypes {
    return @[@(TBAEventTypePreseason), @(TBAEventTypeRegional), @(TBAEventTypeDistrict), @(TBAEventTypeDistrictCMP), @(TBAEventTypeCMPDivision), @(TBAEventTypeCMPFinals), @(TBAEventTypeOffseason), @(TBAEventTypeUnlabeled)];
}

+ (NSString *)nameForEventType:(TBAEventType)type {
    switch (type) {
        case TBAEventTypeRegional:
            return @"Regional";
        case TBAEventTypeDistrict:
            return @"District";
        case TBAEventTypeDistrictCMP:
            return @"District Championship";
        case TBAEventTypeCMPDivision:
            return @"Championship Division";
        case TBAEventTypeCMPFinals:
            return @"Championship Finals";
        case TBAEventTypeOffseason:
            return @"Offseason";
        case TBAEventTypePreseason:
            return @"Preseason";
        case TBAEventTypeUnlabeled:
            return @"--";
    }
}

@end
