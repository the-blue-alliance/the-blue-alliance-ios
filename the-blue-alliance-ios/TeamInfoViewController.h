//
//  TeamInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBATopMapInfoViewController.h"
#import "Team.h"

@interface TeamInfoViewController : TBATopMapInfoViewController
@property (nonatomic, strong) Team *team;
@end
