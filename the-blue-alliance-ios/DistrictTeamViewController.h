//
//  DistrictTeamViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@class District, DistrictRanking;

@interface DistrictTeamViewController : TBAViewController

@property (nonatomic, strong) District *district;
@property (nonatomic, strong) DistrictRanking *districtRanking;

@end
