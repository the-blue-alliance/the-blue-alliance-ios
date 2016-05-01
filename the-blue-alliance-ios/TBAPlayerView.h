//
//  TBAPlayerView.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchVideo, Media;

@interface TBAPlayerView : UIView

@property (nonatomic, strong) MatchVideo *matchVideo;
@property (nonatomic, strong) Media *media;

@end
