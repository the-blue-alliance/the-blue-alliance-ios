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

@end

@implementation EventInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    
    MKMapView *mapView = [[MKMapView alloc] initForAutoLayout];
    [self.view addSubview:mapView];
    [mapView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [mapView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [mapView autoSetDimension:ALDimensionHeight toSize:240];
    mapView.backgroundColor = [UIColor redColor];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.event.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
        MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
        mapView.region = coordRegion;
    }];

}

- (void)dateTapped:(UIButton *)button
{
    NSLog(@"Date tapped... save event to calendar?");
}

- (void)locationTapped:(UIButton *)button
{
    NSLog(@"Location tapped... open in maps?");
}



@end
