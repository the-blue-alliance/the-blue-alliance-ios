//
//  DistrictRankingTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBADistrictRankingTableViewCell.h"
#import "DistrictRanking.h"
#import "Team.h"

@interface TBADistrictRankingTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *teamNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointsLabel;

@end

@implementation TBADistrictRankingTableViewCell

- (void)setDistrictRanking:(DistrictRanking *)districtRanking {
    _districtRanking = districtRanking;
    
    self.teamNumberLabel.text = [NSString stringWithFormat:@"%@", _districtRanking.team.teamNumber];
    self.rankLabel.text = [NSString stringWithFormat:@"Rank %@", _districtRanking.rank];
    self.teamNameLabel.text = [_districtRanking.team nickname];
    self.pointsLabel.text = [NSString stringWithFormat:@"%@ Points", _districtRanking.pointTotal];
}

@end
