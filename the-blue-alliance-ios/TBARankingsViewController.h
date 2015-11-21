//
//  TBARankingsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class District, Event;

@interface TBARankingsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) District *district;
@property (nonatomic, strong) Event *event;

@property (nonatomic, copy) void (^rankingSelected)(id ranking);

@end
