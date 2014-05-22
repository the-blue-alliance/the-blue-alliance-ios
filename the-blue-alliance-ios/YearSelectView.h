//
//  YearSelectTableView.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YearSelect
- (void)didSelectNewYear:(NSInteger)year;
@end

@interface YearSelectView : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithDelegate:(id)delegate currentYear:(NSInteger)year;
@end
