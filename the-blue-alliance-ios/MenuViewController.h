//
//  MenuViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

/** `MenuViewController`'s delegate methods—defined by the MenuViewControllerDelegate protocol
 *  calls menuViewController:didSelectMenuItem: when a new menu item is selected
 */
@class MenuViewController;
@protocol MenuViewControllerDelegate <NSObject>

/** Called when a menu item is tapped
 *
 * @param menu The menu object an item was selected on
 * @param menuItem The object selected
 */
- (void)menuViewController:(MenuViewController *)menu didSelectMenuItem:(NSString *)menuItem;

@end

/** `MenuViewController` is the view controller for the sidebar menu
 */
@interface MenuViewController : UIViewController

/** The object that is notified when a menu item is selected
 */
@property (nonatomic, weak) id<MenuViewControllerDelegate> delegate;

/** A list of items that will be displayed in the menu
 */
@property (nonatomic, copy) NSArray *menuItems;

/** Initilizes the MenuViewController with an array of items
 *
 * @param items An array of NSStrings to show in the menu
 * @return An initilized MenuViewController
 */
- (instancetype)initWithMenuItems:(NSArray *)items;

@end
