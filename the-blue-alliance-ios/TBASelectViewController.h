//
//  SelectYearViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAContainerTableViewController.h"

typedef NS_ENUM(NSInteger, TBASelectType) {
    TBASelectTypeWeek,
    TBASelectTypeYear
};

@interface TBASelectViewController : TBAContainerTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, assign) TBASelectType selectType;

@property (nonatomic, strong) NSNumber *currentNumber;
@property (nonatomic, copy) NSArray<NSNumber *> *numbers;

@property (nonatomic, copy) void (^numberSelected)(NSNumber *number);

@end
