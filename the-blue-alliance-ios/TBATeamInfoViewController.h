//
//  TBATeamInfoViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Team;

@interface TBATeamInfoViewController : TBARefreshTableViewController

@property (nonatomic, strong) Team *team;

@end
