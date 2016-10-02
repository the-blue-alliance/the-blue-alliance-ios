//
//  TBAPointsViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class District, Event;

@interface TBAPointsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) District *district;
@property (nonatomic, strong) Event *event;

@property (nonatomic, copy) void (^pointsSelected)(id points);

@end
