//
//  TBAMyTBATableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAMyTBATableViewCell.h"

@implementation TBAMyTBATableViewCell

- (IBAction)settingsButtonTapped:(id)sender {
    if (self.settingsButtonTapped) {
        self.settingsButtonTapped();
    }
}

@end
