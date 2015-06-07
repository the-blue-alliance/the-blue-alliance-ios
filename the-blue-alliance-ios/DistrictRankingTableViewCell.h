//
//  DistrictRankingTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistrictRankingTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *teamNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointsLabel;

@end
