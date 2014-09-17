//
//  MovableAccessoryTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "MovableAccessoryTableViewCell.h"

@implementation MovableAccessoryTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r;
    if (self.accessoryView) {
        r = self.accessoryView.frame;
        r.origin.x -= self.rightAccessoryInset;
        self.accessoryView.frame = r;
    } else {
        UIView* defaultAccessoryView = nil;
        for (UIView* subview in self.contentView.superview.subviews) {
            if (subview != self.textLabel &&
                subview != self.detailTextLabel &&
                subview != self.backgroundView &&
                subview != self.contentView &&
                subview != self.selectedBackgroundView &&
                subview != self.imageView &&
                subview.frame.origin.x > self.bounds.size.width / 2)
            {
                defaultAccessoryView = subview;
                break;
            }
        }
        r = defaultAccessoryView.frame;
        r.origin.x -= self.rightAccessoryInset;
        defaultAccessoryView.frame = r;
    }
}
@end
