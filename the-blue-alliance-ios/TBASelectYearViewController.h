//
//  SelectYearViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBATableViewController.h"

@interface TBASelectYearViewController : TBATableViewController <TBATableViewControllerDelegate>

@property (nonatomic, assign) NSUInteger currentYear;
@property (nonatomic, copy) NSArray *years;

@property (nonatomic, copy) void (^yearSelectedCallback)(NSUInteger selectedYear);

@end
