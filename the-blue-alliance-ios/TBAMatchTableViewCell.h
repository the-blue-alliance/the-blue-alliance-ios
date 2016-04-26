//
//  TBAMatchTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class Match;

@interface TBAMatchTableViewCell : TBATableViewCell

@property (nonatomic, strong) Match *match;

@end
