//
//  TBAAllianceTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class EventAlliance, Team;

@interface TBAAllianceTableViewCell : TBATableViewCell

@property (nonatomic, strong) EventAlliance *eventAlliance;
@property (nonatomic, copy) void (^teamSelected)(Team *team);

@end
