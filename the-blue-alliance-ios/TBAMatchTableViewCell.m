//
//  TBAMatchTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMatchTableViewCell.h"

@interface TBAMatchTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *matchNumberLabel;

@end

@implementation TBAMatchTableViewCell

- (void)setMatch:(Match *)match {
    _match = match;
    
    self.matchNumberLabel.text = _match.key;
}

@end
