//
//  TBAMediaCollectionViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/14/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface TBAMediaCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) Media *media;

@property (nonatomic, copy) void (^imageLoadedFromWeb)();

@end
