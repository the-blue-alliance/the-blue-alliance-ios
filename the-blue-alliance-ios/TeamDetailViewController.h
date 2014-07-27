//
//  TeamDetailViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
#import "TBAPaginatedViewController.h"

@interface TeamDetailViewController : TBAPaginatedViewController

@property (nonatomic, strong) Team *team;

@end
