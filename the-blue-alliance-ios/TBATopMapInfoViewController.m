//
//  TBATopMapInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBATopMapInfoViewController.h"
#import <MapKit/MapKit.h>


@implementation TBATopMapInfoViewControllerInfoRowObject
@end


@interface TBATopMapInfoViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *infoTable;
@property (nonatomic, strong) NSArray *infoArray; // Array of EventInfoDataDisplay objects
@property (nonatomic, strong) NSLayoutConstraint *tableHeightConstraint;
@end

@implementation TBATopMapInfoViewController


- (NSString *)locationString
{
    return @"";
}

- (NSString *)mapTitle
{
    return @"";
}

- (NSArray *)loadInfoObjects
{
    return @[];
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
        [geocoder geocodeAddressString:[self locationString] completionHandler:^(NSArray *placemarks, NSError *error) {
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
    eventTitle.text = [self mapTitle];
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
    
    [self setupInfoArray];
}

- (void)setupInfoArray
{
    self.infoArray = [self loadInfoObjects];
    [self.infoTable reloadData];
    
    self.tableHeightConstraint.constant = self.infoArray.count * 44;
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
    
    TBATopMapInfoViewControllerInfoRowObject *info = self.infoArray[indexPath.row];
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
