//
//  TBAMyTBATableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@interface TBAMyTBATableViewCell : TBATableViewCell

@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (nonatomic, copy) void (^settingsButtonTapped)();

@end
