//
//  TBATableViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/11/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBATableViewController : UITableViewController

- (void)showNoDataViewWithText:(NSString *)text;
- (void)hideNoDataView;

@end
