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

@property (nonatomic, strong) UIBarButtonItem *activityBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;

@property (nonatomic, strong) NSMutableArray *requestsArray;

@end

@implementation TBARefreshViewController

#pragma mark - Properities

- (UIBarButtonItem *)activityBarButtonItem {
    if (!_activityBarButtonItem) {
        UIActivityIndicatorView *refreshActivityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [refreshActivityView sizeToFit];
        [refreshActivityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
        [refreshActivityView startAnimating];
        
        _activityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshActivityView];
    }
    return _activityBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_refresh_white"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTapped:)];
    }
    return _refreshBarButtonItem;
}

- (NSMutableArray *)requestsArray {
    if (!_requestsArray) {
        _requestsArray = [[NSMutableArray alloc] init];
    }
    return _requestsArray;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:self.refreshBarButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
}

#pragma mark - Public Methods

- (void)updateRefreshBarButtonItem:(BOOL)refreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshing) {
            [self.navigationItem setRightBarButtonItem:self.activityBarButtonItem animated:YES];
        } else {
            [self.navigationItem setRightBarButtonItem:self.refreshBarButtonItem animated:YES];
        }
    });
}

- (void)cancelRefresh {
    [self updateRefreshBarButtonItem:NO];
    
    if ([self.requestsArray count] == 0) {
        return;
    }
    NSLog(@"Refresh canceled");

    for (NSNumber *request in self.requestsArray) {
        NSUInteger requestIdentifier = [request unsignedIntegerValue];
        [[TBAKit sharedKit] cancelRequestWithIdentifier:requestIdentifier];
    }
    [self.requestsArray removeAllObjects];
}

- (void)addRequestIdentifier:(NSUInteger)requestIdentifier {
    [self.requestsArray addObject:@(requestIdentifier)];
}

- (void)removeRequestIdentifier:(NSUInteger)requestIdentifier {
    if (![self.requestsArray containsObject:@(requestIdentifier)]) {
        return;
    }
    [self.requestsArray removeObject:@(requestIdentifier)];

    if ([self.requestsArray count] == 0) {
        [self updateRefreshBarButtonItem:NO];
    }
}

#pragma mark - Private Methods

- (void)refreshButtonTapped:(id)sender {
    if (self.refresh) {
        self.refresh();
    }
}

@end
