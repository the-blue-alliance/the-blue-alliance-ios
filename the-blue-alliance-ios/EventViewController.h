//
//  EventViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "TBAPaginatedViewController.h"

/** `EventViewController` is a detail view for event data.
 */
@interface EventViewController : TBAPaginatedViewController

@property (nonatomic, strong) Event *event;

@end
