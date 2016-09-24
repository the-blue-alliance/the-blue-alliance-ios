//
//  TBARefreshTableViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 11/4/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAContainerTableViewController.h"

@interface TBARefreshTableViewController : TBAContainerTableViewController

@property (nonatomic, copy) void (^refresh)();

- (void)addSessionFetcher:(GTMSessionFetcher *)sessionFetcher;
- (void)removeSessionFetcher:(GTMSessionFetcher *)sessionFetcher;

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier;
- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier;

- (BOOL)shouldNoDataRefresh;
- (void)cancelRefresh;

@end
