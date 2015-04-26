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


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:self.refreshBarButtonItem];
}


#pragma mark - Public Methods

- (void)updateRefreshBarButtonItem:(BOOL)refreshing {
    if (refreshing) {
        [self.navigationItem setRightBarButtonItem:self.activityBarButtonItem animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:self.refreshBarButtonItem animated:YES];
    }
}

- (void)cancelRefresh {
    if (self.currentRequestIdentifier != 0) {
        [[TBAKit sharedKit] cancelRequestWithIdentifier:self.currentRequestIdentifier];
        self.currentRequestIdentifier = 0;
    }
}


#pragma mark - Private Methods

- (void)refreshButtonTapped:(id)sender {
    if (self.refresh) {
        self.refresh();
    }
}

@end
