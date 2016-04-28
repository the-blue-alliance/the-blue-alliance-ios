//
//  TBARefreshViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@interface TBARefreshViewController : TBAViewController

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, copy) void (^refresh)();

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier;
- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier;

- (BOOL)shouldNoDataRefresh;
- (void)cancelRefresh;

@end
