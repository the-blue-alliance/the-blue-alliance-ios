//
//  SelectYearTransitionAnimation.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "SelectYearTransitionAnimator.h"
#import "EventsViewController.h"
#import "SelectYearViewController.h"


static CGFloat const kAnimationDuration = 0.2f;


@implementation SelectYearTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self presentSelectYearViewController:transitionContext];
    } else {
        [self dismissSelectYearViewController:transitionContext];
    }
}

- (void)presentSelectYearViewController:(id<UIViewControllerContextTransitioning>)transitionContext {
    EventsViewController *fromVC = (EventsViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    SelectYearViewController *toVC = (SelectYearViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];

    fromView.userInteractionEnabled = NO;
    
    // Round the corners
    toView.layer.cornerRadius = 5;
    toView.layer.masksToBounds = YES;
    
    // Put below the view
    CGRect newToViewFrame = toView.frame;
    newToViewFrame.origin.y = CGRectGetMaxY(containerView.frame);
    toView.frame = newToViewFrame;
    [containerView addSubview:toView];
    
    // Scale to 90%
    toView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    
    // Animate up
    [UIView animateWithDuration:kAnimationDuration animations:^{
        toView.center = containerView.center;
        fromView.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)dismissSelectYearViewController:(id<UIViewControllerContextTransitioning>)transitionContext {
    SelectYearViewController *fromVC = (SelectYearViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    EventsViewController *toVC = (EventsViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    
    CGRect newFromViewFrame = fromView.frame;
    newFromViewFrame.origin.y = CGRectGetMaxY(containerView.frame);
    
    [UIView animateWithDuration:kAnimationDuration animations: ^{
        fromView.frame = newFromViewFrame;
        toView.alpha = 1.0;
    } completion: ^(BOOL finished) {
        [fromView removeFromSuperview];
        toView.userInteractionEnabled = YES;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
