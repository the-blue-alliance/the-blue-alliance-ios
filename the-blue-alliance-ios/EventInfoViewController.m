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

- (NSString *)locationString
{
    return self.event.location;
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




@end
