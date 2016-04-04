//
//  DistrictRankingTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventPoints, EventRanking, DistrictRanking;

@interface TBARankingTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *rankLabel;

@property (nonatomic, strong) DistrictRanking *districtRanking;
@property (nonatomic, strong) EventRanking *eventRanking;
@property (nonatomic, strong) EventPoints *eventPoints;

@end
