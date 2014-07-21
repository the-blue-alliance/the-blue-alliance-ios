//
//  TeamInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamInfoViewController.h"

@interface TeamInfoViewController ()

@end

@implementation TeamInfoViewController



- (NSString *)title {
    return @"Info";
}


#pragma mark - TBATopMapInfoViewController overrides
- (NSString *)mapTitle
{
    return [NSString stringWithFormat:@"%@\nfrom %@", self.team.nickname, self.team.location];
}

- (NSArray *)loadInfoObjects
{
    TBATopMapInfoViewControllerInfoRowObject *websiteInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    websiteInfo.text = self.team.website.length ? self.team.website : @"No website";
    websiteInfo.icon = [UIImage imageNamed:@"website"];
    
    TBATopMapInfoViewControllerInfoRowObject *rookieYearInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    rookieYearInfo.text = [NSString stringWithFormat:@"Rookie year: %@", self.team.rookieYear];
    rookieYearInfo.icon = [UIImage imageNamed:@"calendar"];
    
    TBATopMapInfoViewControllerInfoRowObject *locationInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    locationInfo.text = self.team.location;
    locationInfo.icon = [UIImage imageNamed:@"location"];
    
    return @[websiteInfo, rookieYearInfo, locationInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(ABS(self.team.cachedLocationRadius.doubleValue) > DBL_EPSILON) {
        self.mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.team.cachedLocationLatValue, self.team.cachedLocationLonValue), 2*self.team.cachedLocationRadiusValue, 2*self.team.cachedLocationRadiusValue);
    } else {
        // Maybe this made it faster?
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Geocode location of event (city, state)
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:self.team.location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
                MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
                self.team.cachedLocationLatValue = region.center.latitude;
                self.team.cachedLocationLonValue = region.center.longitude;
                self.team.cachedLocationRadiusValue = region.radius;
                
                self.mapRegion = coordRegion;
            }];
        });
    }
}

@end
