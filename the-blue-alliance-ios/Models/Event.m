#import "Event.h"
#import "Media.h"
#import <MapKit/MapKit.h>
#import "GeocodeQueue.h"

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
    
    
    if([info[@"location"] length] && [info[@"location"] rangeOfString:@"Vegas"].location != NSNotFound) {
        NSLog(@"VEGAS 1!");
    }
    
    // Asynchronously geocode
    
    
    NSString *textForGeocode = [info[@"venue_address"] length] ? info[@"venue_address"] : info[@"location"];
    if([textForGeocode length] > 0) {
        [[GeocodeQueue sharedGeocodeQueue] addTextToGeocodeQueue:textForGeocode withCallback:^(NSArray *placemarks, NSError *error) {
            CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
            [context performBlock:^{
                if(info[@"location"] && [info[@"location"] rangeOfString:@"Vegas"].location != NSNotFound) {
                    NSLog(@"VEGAS 2!");
                }
                if(region) {
                    self.cachedLocationLatValue = region.center.latitude;
                    self.cachedLocationLonValue = region.center.longitude;
                    self.cachedLocationRadiusValue = region.radius;
//                    NSLog(@"Finished geocoding %@", info[@"location"]);
                } else {
                    NSLog(@"Error: %@  while trying to geocode: %@", error, textForGeocode);
                }
            }];
        }];
    }
    
    
    // TODO: Finish / improve importing
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.cachedLocationLatValue, self.cachedLocationLonValue);
}

- (NSString *)title
{
    return self.short_name;
}

- (NSString *)subtitle
{
    return self.location;
}

@end
