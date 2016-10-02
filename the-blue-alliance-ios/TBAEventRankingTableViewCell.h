//
//  DistrictRankingTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

static NSString *const RankCellReuseIdentifier  = @"RankCell";

@class EventRanking;

@interface TBAEventRankingTableViewCell : TBATableViewCell

@property (nonatomic, strong) EventRanking *eventRanking;

@end
