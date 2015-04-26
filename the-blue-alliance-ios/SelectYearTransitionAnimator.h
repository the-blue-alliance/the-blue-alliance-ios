//
//  SelectYearTransitionAnimation.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectYearTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
