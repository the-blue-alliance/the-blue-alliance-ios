//
//  TBAYearSelectViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshViewController.h"

@interface TBAYearSelectViewController : TBARefreshViewController

@property (nonatomic, assign) NSInteger startYear;
@property (nonatomic, assign) NSUInteger currentYear;

@property (nonatomic, copy) void (^yearSelected)(NSUInteger year);

@end
