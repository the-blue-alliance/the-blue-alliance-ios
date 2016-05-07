//
//  TBAViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/28/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"
#import "TBANavigationController.h"
#import "TBARefreshViewController.h"

@interface TBAViewController ()

@property (nullable, nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nullable, nonatomic, strong) IBOutlet UIView *segmentedControlView;

@end

@implementation TBAViewController

#pragma mark - Properities

- (TBAPersistenceController *)persistenceController {
    TBANavigationController *navigationController = (TBANavigationController *)self.navigationController;
    return navigationController.persistenceController;
}

- (void)setRefreshViewControllers:(NSArray *)refreshViewControllers {
    _refreshViewControllers = refreshViewControllers;
    
    for (TBARefreshViewController *refreshViewController in refreshViewControllers) {
        refreshViewController.persistenceController = self.persistenceController;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSegmentedControlViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefreshes];
}

#pragma mark - Private Methods

- (void)updateSegmentedControlViews {
    if (!self.segmentedControl && self.containerViews.count == 1) {
        [self showView:self.containerViews.firstObject];
    } else if (self.segmentedControl && self.containerViews.count > self.segmentedControl.selectedSegmentIndex) {
        UIView *showView = self.containerViews[self.segmentedControl.selectedSegmentIndex];
        [self showView:showView];
    }
}

- (void)showView:(UIView *)showView {
    for (int i = 0; i < self.containerViews.count; i++) {
        UIView *containerView = self.containerViews[i];
        
        BOOL shouldHideView = (containerView == showView ? NO : YES);
        if (!shouldHideView) {
            // Check if our view controller is in a no data state, refresh if it is
            TBARefreshViewController *refreshViewController = self.refreshViewControllers[i];
            if ([refreshViewController shouldNoDataRefresh]) {
                refreshViewController.refresh();
            }
        }
        containerView.hidden = shouldHideView;
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
    [self updateSegmentedControlViews];
}

@end
