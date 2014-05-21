//
//  YearSelectTableView.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearSelectTableView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) BOOL showing;
@property (nonatomic) NSInteger currentYear;

- (void)show;
- (void)hide;
@end
