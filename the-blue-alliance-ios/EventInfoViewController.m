//
//  EventInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/26/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventInfoViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface EventInfoViewController ()
@property (nonatomic, strong) UITableView *infoTable;
@property (nonatomic, strong) NSArray *infoArray; // Array of EventInfoDataDisplay objects
@property (nonatomic, strong) NSLayoutConstraint *tableHeightConstraint;
@end

@implementation EventInfoViewController


- (NSString *)title {
    return @"Info";
}


#pragma mark - TBATopMapInfoViewController overrides
- (NSString *)mapTitle
{
    return self.event.friendlyName;
}

- (NSArray *)loadInfoObjects
{
    TBATopMapInfoViewControllerInfoRowObject *websiteInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    websiteInfo.text = self.event.website.length ? self.event.website : @"No website";
    websiteInfo.icon = [UIImage imageNamed:@"website"];
    
    TBATopMapInfoViewControllerInfoRowObject *dateInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    dateInfo.text = [self eventDateFriendlyText];
    dateInfo.icon = [UIImage imageNamed:@"calendar"];
    
    TBATopMapInfoViewControllerInfoRowObject *locationInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    locationInfo.text = self.event.location;
    locationInfo.icon = [UIImage imageNamed:@"location"];
    
    return @[websiteInfo, dateInfo, locationInfo];
}

// Helper method
- (NSString *)eventDateFriendlyText
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    return [NSString stringWithFormat:@"%@ to %@", [formatter stringFromDate:self.event.start_date], [formatter stringFromDate:self.event.end_date]];
}



- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    if(ABS(self.event.cachedLocationRadius.doubleValue) > DBL_EPSILON) {
        self.mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.event.cachedLocationLatValue, self.event.cachedLocationLonValue), 2*self.event.cachedLocationRadiusValue, 2*self.event.cachedLocationRadiusValue);
    } else {
        // Maybe this made it faster?
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Geocode location of event (city, state)
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:self.event.location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
                MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
                self.event.cachedLocationLatValue = region.center.latitude;
                self.event.cachedLocationLonValue = region.center.longitude;
                self.event.cachedLocationRadiusValue = region.radius;

                self.mapRegion = coordRegion;
            }];
        });
    }
}



@end
