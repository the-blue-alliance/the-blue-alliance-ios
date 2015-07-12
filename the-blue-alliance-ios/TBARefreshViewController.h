//
//  TBARefreshViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@interface TBARefreshViewController : TBAViewController

@property (nonatomic, copy) void (^refresh)();

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier;
- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier;

- (void)updateRefreshBarButtonItem:(BOOL)refreshing;
- (void)cancelRefresh;

@end
