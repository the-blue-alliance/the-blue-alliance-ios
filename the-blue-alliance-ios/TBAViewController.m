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

- (void)updateInterface {
    // Implement in subview
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
