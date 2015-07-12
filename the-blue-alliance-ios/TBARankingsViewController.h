//
//  TBARankingsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class District;

@interface TBARankingsViewController : TBATableViewController

@property (nonatomic, strong) District *district;

@property (nonatomic, copy) NSArray *rankings;
@property (nonatomic, copy) void (^rankingSelected)(id ranking);

@end
