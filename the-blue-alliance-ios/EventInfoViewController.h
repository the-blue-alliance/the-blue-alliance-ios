//
//  EventInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/26/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

/** `EventInfoViewController` is a subview of `EventViewController`
 *  This view shows information for a specific event, such as date,
 *  location, top teams, etc
 */
@interface EventInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Event *event;

@end