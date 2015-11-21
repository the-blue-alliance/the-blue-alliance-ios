//
//  TBAYearSelectViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshViewController.h"

@interface TBAYearSelectViewController : TBAViewController

@property (nonatomic, assign) NSUInteger currentYear;
@property (nonatomic, copy) NSArray *years;

@property (nonatomic, copy) void (^yearSelected)(NSUInteger year);

+ (NSInteger)currentYear;
+ (NSArray *)yearsBetweenStartYear:(NSInteger)startYear endYear:(NSInteger)endYear;

@end
