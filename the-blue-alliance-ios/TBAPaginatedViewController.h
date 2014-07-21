//
//  TBAPaginatedViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBAPaginatedViewController : UIViewController


// Override in subclasses to provide view controllers;
- (NSArray *)loadViewControllers;

@end
