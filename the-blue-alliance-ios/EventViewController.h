//
//  EventViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 4/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshViewController.h"

@class Event;

@interface EventViewController : TBARefreshViewController

@property (nonatomic, strong) Event *event;

/*
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *socialButtons;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;
*/
@end
