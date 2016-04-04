//
//  TBAAwardsViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event;

@interface TBAAwardsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) Event *event;

@end
