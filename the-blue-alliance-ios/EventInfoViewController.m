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


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwise autolayout freaks out and moves subviews...
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *dateLabel = [[UILabel alloc] initForAutoLayout];
    [self.view addSubview:dateLabel];
    [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
    [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    dateLabel.text = [NSString stringWithFormat:@"%@ to %@", [formatter stringFromDate:self.event.start_date], [formatter stringFromDate:self.event.end_date]];
    dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

}


@end
