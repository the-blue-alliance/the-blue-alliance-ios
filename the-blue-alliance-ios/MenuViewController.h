//
//  MenuViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuViewController;
@protocol MenuViewControllerDelegate <NSObject>

- (void) menuViewControllerDidSelectEvents:(MenuViewController *)menu;
- (void) menuViewControllerDidSelectTeams:(MenuViewController *)menu;
- (void) menuViewControllerDidSelectInsights:(MenuViewController *)menu;
- (void) menuViewControllerDidSelectSettings:(MenuViewController *)menu;


@end

@interface MenuViewController : UIViewController

@property (nonatomic, copy) NSArray *menuItems;

- (instancetype) initWithMenuItems:(NSArray *)items;

@end
