//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()
@property (nonatomic, strong) Event *event;
@end

@implementation EventViewController

- (instancetype) initWithEvent:(Event *)event
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if(self) {
        self.event = event;
        self.dataSource = self;
    }
    return self;
}

@end
