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
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation TBATopMapInfoViewController




- (NSString *)mapTitle
{
    return @"";
}

- (NSArray *)loadInfoObjects
{
    return @[];
}


- (void)setMapRegion:(MKCoordinateRegion)mapRegion
{
    _mapRegion = mapRegion;
    self.mapView.region = mapRegion;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // Setup map view
    self.mapView = [[MKMapView alloc] initForAutoLayout];
    [self.view addSubview:self.mapView];
    [self.mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.mapView autoSetDimension:ALDimensionHeight toSize:120];
    
    
    
    // Setup event title overlay over map
    UIView *darkOverlay = [[UIView alloc] initForAutoLayout];
    darkOverlay.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    [self.mapView addSubview:darkOverlay];
    [darkOverlay autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UILabel *eventTitle = [[UILabel alloc] initForAutoLayout];
    eventTitle.text = [self mapTitle];
    eventTitle.textColor = [UIColor whiteColor];
    eventTitle.font = [UIFont boldSystemFontOfSize:24];
    eventTitle.textAlignment = NSTextAlignmentLeft;
    eventTitle.numberOfLines = 0;
    eventTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [self.mapView addSubview:eventTitle];
    [eventTitle autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(8, 8, 8, 8) excludingEdge:ALEdgeTop];
    
    
    // Setup table view
    self.infoTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.infoTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoTable.dataSource = self;
    self.infoTable.delegate = self;
    [self.view addSubview:self.infoTable];
    [self.infoTable autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mapView];
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
