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

- (void) menuViewController:(MenuViewController *)menu didSelectMenuItem:(NSString *)menuItem;

@end

@interface MenuViewController : UIViewController

@property (nonatomic, weak) id<MenuViewControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *menuItems;

- (instancetype) initWithMenuItems:(NSArray *)items;

@end
