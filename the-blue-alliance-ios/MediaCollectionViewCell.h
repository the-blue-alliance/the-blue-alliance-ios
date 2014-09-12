//
//  MediaCollectionViewCell.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface MediaCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) Media *media;
@property (nonatomic, readonly) UIImageView *imageView;

@end
