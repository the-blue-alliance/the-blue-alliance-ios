//
//  MatchViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@class Match, Team;

@interface MatchViewController : TBAViewController

@property (nonatomic, strong) Match *match;
@property (nonatomic, strong) Team *team;

@end
