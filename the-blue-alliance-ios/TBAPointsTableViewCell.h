//
//  TBAPointsTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class DistrictRanking, EventPoints;

@interface TBAPointsTableViewCell : TBATableViewCell

@property (nonatomic, strong) IBOutlet UILabel *rankLabel;

@property (nonatomic, strong) DistrictRanking *districtRanking;
@property (nonatomic, strong) EventPoints *eventPoints;

@end
