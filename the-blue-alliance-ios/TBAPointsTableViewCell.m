//
//  TBAPointsTableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAPointsTableViewCell.h"
#import "DistrictRanking.h"
#import "EventPoints.h"
#import "Team.h"

@interface TBAPointsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *teamNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@end

@implementation TBAPointsTableViewCell

- (void)setDistrictRanking:(DistrictRanking *)districtRanking {
    _districtRanking = districtRanking;
    
    self.teamNumberLabel.text = [NSString stringWithFormat:@"%@", _districtRanking.team.teamNumber];
    self.rankLabel.text = [NSString stringWithFormat:@"Rank %@", _districtRanking.rank];
    self.teamNameLabel.text = [_districtRanking.team nickname];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ Points", _districtRanking.pointTotal];
}

- (void)setEventPoints:(EventPoints *)eventPoints {
    _eventPoints = eventPoints;
    
    self.teamNumberLabel.text = [NSString stringWithFormat:@"%@", _eventPoints.team.teamNumber];
    self.teamNameLabel.text = [_eventPoints.team nickname];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ Points", _eventPoints.total];
}

@end
