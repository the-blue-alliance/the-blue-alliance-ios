//
//  EventsViewController.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAYearSelectViewController.h"


static NSString *const EventTapped  = @"EventTapped";


@interface EventsViewController : TBAYearSelectViewController

@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@end
