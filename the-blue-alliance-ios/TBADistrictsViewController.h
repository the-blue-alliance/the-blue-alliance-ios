//
//  TBADistrictsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/12/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class District;

@interface TBADistrictsViewController : TBATableViewController

@property (nonatomic, copy) NSArray *districts;

@property (nonatomic, copy) void (^districtSelected)(District *district);

@end
