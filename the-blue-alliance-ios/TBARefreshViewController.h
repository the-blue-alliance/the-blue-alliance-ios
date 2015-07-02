//
//  TBARefreshViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAViewController.h"

@interface TBARefreshViewController : TBAViewController

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) NSUInteger currentRequestIdentifier;
@property (nonatomic, copy) void (^refresh)();

- (void)updateRefreshBarButtonItem:(BOOL)refreshing;
- (void)cancelRefresh;

@end
