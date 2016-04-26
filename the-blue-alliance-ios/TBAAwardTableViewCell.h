//
//  TBAAwardTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class Award;

@interface TBAAwardTableViewCell : TBATableViewCell

@property (nonatomic, strong) Award *award;

@end
