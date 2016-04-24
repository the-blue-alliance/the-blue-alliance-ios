//
//  TBASelectWeekViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@interface TBASelectWeekViewController : TBAViewController

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *weekLabel;

@property (nonatomic, strong) NSNumber *currentWeek;
@property (nonatomic, copy) NSArray<NSNumber *> *weeks;

@property (nonatomic, copy) void (^weekSelected)(NSNumber *week);

+ (NSNumber *)currentWeek;

@end
