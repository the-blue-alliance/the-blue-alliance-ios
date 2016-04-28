//
//  TBARefreshCollectionViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 11/20/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshCollectionViewController.h"
#import "TBAKit.h"

@interface TBARefreshCollectionViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *requestsArray;

@end

@implementation TBARefreshCollectionViewController

#pragma mark - Properities

- (NSMutableArray *)requestsArray {
    if (!_requestsArray) {
        _requestsArray = [[NSMutableArray alloc] init];
    }
    return _requestsArray;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    // Make sure our refresh control is above the background view so it shows during no data states
    self.refreshControl.layer.zPosition = self.collectionView.backgroundView.layer.zPosition + 1;
    
    self.collectionView.alwaysBounceVertical = YES;
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
            [self.collectionView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
            [self.refreshControl beginRefreshing];
        } else {
            [self.refreshControl endRefreshing];
        }
    });
}

@end
