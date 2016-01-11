//
//  TBAAlliancesTableViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event;

@interface TBAAlliancesViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) Event *event;

//@property (nonatomic, copy) void (^rankingSelected)(id ranking);

@end
