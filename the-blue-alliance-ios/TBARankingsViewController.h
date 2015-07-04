//
//  TBARankingsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class District;

@interface TBARankingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) District *district;

@property (nonatomic, copy) NSArray *rankings;
@property (nonatomic, copy) void (^rankingSelected)(id ranking);

@end
