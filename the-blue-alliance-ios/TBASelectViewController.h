//
//  SelectYearViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

typedef NS_ENUM(NSInteger, TBASelectType) {
    TBASelectTypeWeek,
    TBASelectTypeYear
};

@interface TBASelectViewController : TBATableViewController <TBATableViewControllerDelegate>

@property (nonatomic, assign) TBASelectType selectType;

@property (nonatomic, strong) NSNumber *currentNumber;
@property (nonatomic, copy) NSArray<NSNumber *> *numbers;

@property (nonatomic, copy) void (^numberSelected)(NSNumber *number);

@end
