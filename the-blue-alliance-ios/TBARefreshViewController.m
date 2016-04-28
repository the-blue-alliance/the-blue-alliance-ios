//
//  TBARefreshViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshViewController.h"
#import "TBAKit.h"

@interface TBARefreshViewController ()

@property (nonatomic, strong) NSMutableArray *requestsArray;

@end

@implementation TBARefreshViewController

#pragma mark - Properities

- (NSMutableArray *)requestsArray {
    if (!_requestsArray) {
        _requestsArray = [[NSMutableArray alloc] init];
    }
    return _requestsArray;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

#pragma mark - View Lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
}

#pragma mark - Public Methods

- (BOOL)shouldNoDataRefresh {
    // Implement this in subclass
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return NO;
}

- (void)cancelRefresh {
    [self updateRefresh:NO];
    
    if ([self.requestsArray count] == 0) {
        return;
    }
    
    for (NSNumber *request in self.requestsArray) {
        NSUInteger requestIdentifier = [request unsignedIntegerValue];
        [[TBAKit sharedKit] cancelRequestWithIdentifier:requestIdentifier];
    }
    [self.requestsArray removeAllObjects];
}

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier {
    [self.requestsArray addObject:@(requestIdentifier)];
    
    if (self.refreshControl.isRefreshing == NO) {
        [self updateRefresh:YES];
    }
}

- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier {
    if (![self.requestsArray containsObject:@(requestIdentifier)]) {
        return;
    }
    [self.requestsArray removeObject:@(requestIdentifier)];
    
    if ([self.requestsArray count] == 0) {
        [self updateRefresh:NO];
    }
}

#pragma mark - Private Methods

- (void)refresh:(id)sender {
    if (self.refresh) {
        self.refresh();
    }
}

- (void)updateRefresh:(BOOL)refreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshing) {
            [self.refreshControl beginRefreshing];
        } else {
            [self.refreshControl endRefreshing];
        }
    });
}

@end
