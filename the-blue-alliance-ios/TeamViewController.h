//
//  TeamViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/7/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBASelectYearViewController.h"

@class Team;

@interface TeamViewController : TBASelectYearViewController;

@property (nonatomic, weak) Team *team;

@end
