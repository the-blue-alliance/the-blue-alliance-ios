#import "Event.h"
#import "Media.h"

@implementation Event
@dynamic key;

- (NSString *)friendlyName
{
    NSString *withYear = [NSString stringWithFormat:@"%@ %@", self.year, self.short_name ? self.short_name : self.name];
    
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
    self.event_short = info[@"event_code"];
    self.start_date = [formatter dateFromString:info[@"start_date"]] ? [formatter dateFromString:info[@"start_date"]] : defaultDate;
    self.end_date = [formatter dateFromString:info[@"end_date"]];
    self.event_type = info[@"event_type"];
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

@end
