//
//  TBAViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/28/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"
#import "TBARefreshViewController.h"

@implementation TBAViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    
    [self updateInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefreshes];
}

#pragma mark - Public Methods

- (void)updateInterface {
    if (self.segmentedControl && self.containerViews.count > self.segmentedControl.selectedSegmentIndex) {
        UIView *showView = self.containerViews[self.segmentedControl.selectedSegmentIndex];
        [self showView:showView];
    }
}

- (void)showView:(UIView *)showView {
    for (int i = 0; i < self.containerViews.count; i++) {
        UIView *containerView = self.containerViews[i];
        
        BOOL shouldShowView = (containerView == showView ? NO : YES);
        if (shouldShowView) {
            // Check if our view controller is in a no data state, refresh if it is
            TBARefreshViewController *refreshViewController = self.refreshViewControllers[i];
            if ([refreshViewController respondsToSelector:@selector(shouldNoDataRefresh)] && [refreshViewController shouldNoDataRefresh]) {
                refreshViewController.refresh();
            }
        }
        containerView.hidden = shouldShowView;
    }
}

- (void)cancelRefreshes {
    for (TBARefreshViewController *viewController in self.refreshViewControllers) {
        if ([viewController respondsToSelector:@selector(cancelRefresh)]) {
            [viewController cancelRefresh];
        }
    }
}

#pragma mark - IB Actions

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
    [self updateInterface];
}

@end
