//
//  TBARefreshViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBARefreshViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentRequestIdentifier;
@property (nonatomic, copy) void (^refresh)();

- (void)updateRefreshBarButtonItem:(BOOL)refreshing;
- (void)cancelRefresh;

@end
