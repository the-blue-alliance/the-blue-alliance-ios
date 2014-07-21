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

@implementation EventInfoDataDisplay
@end


@interface EventInfoViewController ()
@property (nonatomic, strong) UITableView *infoTable;
@property (nonatomic, strong) NSArray *infoArray; // Array of EventInfoDataDisplay objects
@property (nonatomic, strong) NSLayoutConstraint *tableHeightConstraint;
@end

@implementation EventInfoViewController


- (NSString *)title {
    return @"Info";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    

#warning Maps are pretty slow... what can be done?
#define ENABLE_MAP 1
#if ENABLE_MAP
    // Setup map view
    MKMapView *mapView = [[MKMapView alloc] initForAutoLayout];
    [self.view addSubview:mapView];
    [mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [mapView autoSetDimension:ALDimensionHeight toSize:120];

    // Maybe this made it faster?
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Geocode location of event (city, state)
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:self.event.location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLCircularRegion *region = (CLCircularRegion *)[(CLPlacemark *)[placemarks firstObject] region];
            MKCoordinateRegion coordRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
            mapView.region = coordRegion;
        }];
    });
    
#else
    UIView *mapView = [[UIView alloc] initForAutoLayout];
    [self.view addSubview:mapView];
    [mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [mapView autoSetDimension:ALDimensionHeight toSize:120];
#endif
    
    
    // Setup event title overlay over map
    UIView *darkOverlay = [[UIView alloc] initForAutoLayout];
    darkOverlay.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    [mapView addSubview:darkOverlay];
    [darkOverlay autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UILabel *eventTitle = [[UILabel alloc] initForAutoLayout];
    eventTitle.text = self.event.friendlyName;
    eventTitle.textColor = [UIColor whiteColor];
    eventTitle.font = [UIFont boldSystemFontOfSize:24];
    eventTitle.textAlignment = NSTextAlignmentLeft;
    eventTitle.numberOfLines = 0;
    eventTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [mapView addSubview:eventTitle];
    [eventTitle autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(8, 8, 8, 8) excludingEdge:ALEdgeTop];
    
    
    // Setup table view
    self.infoTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.infoTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoTable.dataSource = self;
    self.infoTable.delegate = self;
    [self.view addSubview:self.infoTable];
    [self.infoTable autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mapView];
    [self.infoTable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.infoTable autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    self.tableHeightConstraint = [self.infoTable autoSetDimension:ALDimensionHeight toSize:300];
    
    [self setupEventInfoArray];
}

- (void)setupEventInfoArray
{
    EventInfoDataDisplay *websiteInfo = [[EventInfoDataDisplay alloc] init];
    websiteInfo.text = self.event.website.length ? self.event.website : @"No website";
    websiteInfo.icon = [UIImage imageNamed:@"website"];
    
    EventInfoDataDisplay *dateInfo = [[EventInfoDataDisplay alloc] init];
    dateInfo.text = [self eventDateFriendlyText];
    dateInfo.icon = [UIImage imageNamed:@"calendar"];
    
    EventInfoDataDisplay *locationInfo = [[EventInfoDataDisplay alloc] init];
    locationInfo.text = self.event.location;
    locationInfo.icon = [UIImage imageNamed:@"location"];
    
    self.infoArray = @[websiteInfo, dateInfo, locationInfo];
    [self.infoTable reloadData];
    
    self.tableHeightConstraint.constant = self.infoArray.count * 44;
}

- (NSString *)eventDateFriendlyText
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    return [NSString stringWithFormat:@"%@ to %@", [formatter stringFromDate:self.event.start_date], [formatter stringFromDate:self.event.end_date]];
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
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.textLabel.text = info.text;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
