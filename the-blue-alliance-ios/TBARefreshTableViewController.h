//
//  TBARefreshTableViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 11/4/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@interface TBARefreshTableViewController : TBATableViewController

@property (nonatomic, copy) void (^refresh)();

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier;
- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier;

- (void)cancelRefresh;

@end
