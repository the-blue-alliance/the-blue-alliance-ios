//
//  TBATableTableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/25/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@implementation TBATableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.preservesSuperviewLayoutMargins = YES;
    self.contentView.preservesSuperviewLayoutMargins = YES;
}

@end
