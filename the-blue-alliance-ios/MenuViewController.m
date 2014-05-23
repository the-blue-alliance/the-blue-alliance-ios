//
//  MenuViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

#pragma mark - Custom Setter
- (void)setMenuItems:(NSArray *)menuItems
{
    _menuItems = [menuItems copy];
    
    [self layoutMenu];
}

- (instancetype)initWithMenuItems:(NSArray *)items
{
    if(self = [super init]) {
        self.menuItems = items;
    }
    return self;
}

#pragma mark - UI Actions
- (void)menuButtonTapped:(UIButton *)button
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(menuViewController:didSelectMenuItem:)])
        [self.delegate menuViewController:self didSelectMenuItem:button.currentTitle];
}

#pragma mark - View creation utility methods
- (UIView *)createSeparatorView
{
    UIView *separator = [[UIView alloc] initForAutoLayout];
    separator.backgroundColor = [UIColor colorWithWhite:0.500 alpha:0.400];
    
    return separator;
}

- (UIButton *)createButtonForTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initForAutoLayout];
    [button setTitle:title forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Main layout routine
- (void)layoutMenu
{   
    if(!self.menuItems.count) {
        return;
    }
    
    // Iterate through each menu item and pin each one to the left edge
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for(NSUInteger i = 0; i < self.menuItems.count; i++) {
        UIButton *itemButton = [self createButtonForTitle:self.menuItems[i]];
        [self.view addSubview:itemButton];
        [itemButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [views addObject:itemButton];
        
        if(i != self.menuItems.count - 1) {
            UIView *itemSeparator = [self createSeparatorView];
            [self.view addSubview:itemSeparator];
            [itemSeparator autoSetDimensionsToSize:CGSizeMake(230, 0.5)];
            [itemSeparator autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
            [views addObject:itemSeparator];
        }
    }
    
    // Center the middle view vertically
    UIView *centerView = views[(views.count - 1) / 2];
    [centerView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    // Pin all the views together in a vertical chain
    for (NSUInteger i = 0; i < views.count - 1; i++) {
        UIView *view = views[i];
        UIView *nextView = views[i + 1];
        [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:nextView withOffset:-16];
    }
}

@end
