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
    
    self.view = [[UIView alloc] init]; // For some reason this needs to be here, otherwhise autolayout freaks out and moves subviews...
    
    UILabel *label = [[UILabel alloc] initForAutoLayout];
    [self.view addSubview:label];
    [label autoCenterInSuperview];
    label.text = self.event.name;

}


@end
