//
//  DistrictRankingTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventRanking, DistrictRanking;

@interface TBARankingTableViewCell : UITableViewCell

@property (nonatomic, strong) DistrictRanking *districtRanking;
@property (nonatomic, strong) EventRanking *eventRanking;

@end
