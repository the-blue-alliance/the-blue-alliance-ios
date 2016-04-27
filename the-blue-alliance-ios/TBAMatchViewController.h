//
//  TBAMatchViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshViewController.h"

@class Match;

@interface TBAMatchViewController : TBARefreshViewController

@property (nonatomic, strong) Match *match;

@end
