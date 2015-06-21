//
//  SelectYearViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectYearViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger startYear;
@property (nonatomic, assign) NSUInteger currentYear;

@property (nonatomic, copy) void (^yearSelectedCallback)(NSUInteger selectedYear);

@end
