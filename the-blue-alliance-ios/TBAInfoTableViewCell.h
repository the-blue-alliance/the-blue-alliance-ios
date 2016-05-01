//
//  TBAInfoTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class Event, Team;

@interface TBAInfoTableViewCell : TBATableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Team *team;

@end
