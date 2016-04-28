//
//  TBAViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"
#import "TBANoDataViewController.h"
#import "TBARefreshViewController.h"

@interface TBAViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;

@end

@implementation TBAViewController

#pragma mark - Public Methods

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showNoDataViewWithText:(NSString *)text {
    if (!self.noDataViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.noDataViewController = [storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    }
    
    self.noDataViewController.view.alpha = 0.0f;
    [self.view addSubview:self.noDataViewController.view];
    
    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.noDataViewController.view.alpha = 1.0f;
    }];
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        [self.noDataViewController.view removeFromSuperview];
    }
}

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
