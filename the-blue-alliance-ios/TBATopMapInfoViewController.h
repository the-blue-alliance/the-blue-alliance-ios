//
//  TBATopMapInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  Simple container class for wrapping the image and text to display for a single row of metadata about an event
 */
@interface TBATopMapInfoViewControllerInfoRowObject : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *icon;
@end


@interface TBATopMapInfoViewController : UIViewController



// Override:
- (NSString *)locationString;
- (NSString *)mapTitle;
- (NSArray *)loadInfoObjects;

@end
