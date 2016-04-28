//
//  TBATeamAtDistrictSummaryViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class DistrictRanking, EventPoints;

@interface TBATeamAtDistrictSummaryViewController : TBARefreshTableViewController

@property (nonatomic, strong) DistrictRanking *districtRanking;

@property (nonatomic, copy) void (^eventPointsSelected)(EventPoints *eventPoints);

@end
