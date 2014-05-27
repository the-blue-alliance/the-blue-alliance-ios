//
//  EventInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/26/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventInfoViewController.h"

@interface EventInfoViewController ()

@end

@implementation EventInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create date label
    UIImage *calendarImage = [UIImage imageNamed:@"calendar"];
    UIImageView *calendar = [[UIImageView alloc] initWithImage:calendarImage];
    calendar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:calendar];
    [calendar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [calendar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [calendar autoSetDimensionsToSize:CGSizeMake(roundf(calendarImage.size.width * 0.8), roundf(calendarImage.size.height * 0.8))];

    UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    dateButton.tintColor = [UIColor TBANavigationBarColor];
    dateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [dateButton addTarget:self action:@selector(dateTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dateButton];
    [dateButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:calendar withOffset:4];
    [dateButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:calendar];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *dateText = [NSString stringWithFormat:@"%@ to %@", [formatter stringFromDate:self.event.start_date], [formatter stringFromDate:self.event.end_date]];
    [dateButton setTitle:dateText forState:UIControlStateNormal];
    
    // Create location label
    UIImage *locationImage = [UIImage imageNamed:@"location"];
    UIImageView *location = [[UIImageView alloc] initWithImage:locationImage];
    location.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:location];
    [location autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [location autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:calendar withOffset:4];
    [location autoSetDimensionsToSize:CGSizeMake(roundf(locationImage.size.width * 0.8), roundf(locationImage.size.height * 0.8))];

    UIButton *locationLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationLabel.tintColor = [UIColor TBANavigationBarColor];
    locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [locationLabel addTarget:self action:@selector(locationTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationLabel];
    [locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:location withOffset:4];
    [locationLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:location];

    [locationLabel setTitle:self.event.location forState:UIControlStateNormal];
    

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
