//
//  TBAMediaView.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface TBAMediaView : UIView

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UIImage *downloadedImage;

@property (nonatomic, copy) void (^imageDownloaded)(UIImage *image);

@end
