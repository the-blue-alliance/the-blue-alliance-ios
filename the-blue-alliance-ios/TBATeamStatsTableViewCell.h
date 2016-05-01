//
//  TBATeamStatsTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class EventTeamStat;

@interface TBATeamStatsTableViewCell : TBATableViewCell

@property (nonatomic, strong) NSArray<EventTeamStat *> *teamStats;

@end
