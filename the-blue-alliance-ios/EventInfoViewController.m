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

/**
 *  Simple container class for wrapping the image and text to display for a single row of metadata about an event
 */
@interface EventInfoDataDisplay : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *icon;
@end


@interface EventInfoViewController ()
@property (nonatomic, strong) NSArray *infoArray; // Array of EventInfoDataDisplay objects
@end

@implementation EventInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Setup map view
    MKMapView *mapView = [[MKMapView alloc] initForAutoLayout];
    [self.view addSubview:mapView];
    [mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [mapView autoSetDimension:ALDimensionHeight toSize:120];

    // Geocode location of event (city, state)
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.event.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
        MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
        mapView.region = coordRegion;
    }];
    
    
    // Setup table view
    UITableView *infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
    infoTableView.dataSource = self;
    [self.view addSubview:infoTableView];
    [infoTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mapView];
    [infoTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];

    [self setupEventInfoArray];
}

- (void)setupEventInfoArray
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Info Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Event Info Cell"];
    }
    
    EventInfoDataDisplay *info = self.infoArray[indexPath.row];
    cell.imageView.image = info.icon;
    cell.textLabel.text = info.text;
    
    return cell;
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
