//
//  TBAInfoTableViewDataRow.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Simple container class for wrapping the image and text to display for a single row of metadata about an event
 */
@interface TBAInfoTableViewDataRow : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *icon;
@end
