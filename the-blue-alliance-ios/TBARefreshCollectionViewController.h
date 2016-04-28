//
//  TBARefreshCollectionViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 11/20/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBACollectionViewController.h"

@interface TBARefreshCollectionViewController : TBACollectionViewController

@property (nonatomic, copy) void (^refresh)();

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier;
- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier;

- (BOOL)shouldNoDataRefresh;
- (void)cancelRefresh;

@end
