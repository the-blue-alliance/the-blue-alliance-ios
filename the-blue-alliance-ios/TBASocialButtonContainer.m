//
//  TBASocialButtonContainer.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBASocialButtonContainer.h"

@implementation TBASocialButtonContainer

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44);
}


#pragma mark - Actions
- (void)buttonTapped:(UIButton *)button
{
    self.selectedButtonType = button.tag;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - View Initialization
- (void)setupUI
{
    // Create views
    UIButton *websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    websiteButton.translatesAutoresizingMaskIntoConstraints = NO;
    websiteButton.backgroundColor = [UIColor colorWithRed:77/255.0 green:79/255.0 blue:135/255.0 alpha:1.0];
    [websiteButton setShowsTouchWhenHighlighted:YES];
    [websiteButton setImage:[UIImage imageNamed:@"website-white"] forState:UIControlStateNormal];
    websiteButton.tag = TBASocialButtonContainerButtonTypeWebsite;
    [websiteButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:websiteButton];
    
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    twitterButton.backgroundColor = [UIColor colorWithRed:89/255.0 green:173/255.0 blue:235/255.0 alpha:1.0];
    [twitterButton setShowsTouchWhenHighlighted:YES];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-white"] forState:UIControlStateNormal];
    twitterButton.tag = TBASocialButtonContainerButtonTypeTwitter;
    [twitterButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:twitterButton];
    
    UIButton *youtubeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    youtubeButton.translatesAutoresizingMaskIntoConstraints = NO;
    youtubeButton.backgroundColor = [UIColor colorWithRed:203/255.0 green:35/255.0 blue:39/255.0 alpha:1.0];
    [youtubeButton setShowsTouchWhenHighlighted:YES];
    [youtubeButton setImage:[UIImage imageNamed:@"youtube-white"] forState:UIControlStateNormal];
    youtubeButton.tag = TBASocialButtonContainerButtonTypeYoutube;
    [youtubeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:youtubeButton];
    
    UIButton *chiefDelphiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chiefDelphiButton.translatesAutoresizingMaskIntoConstraints = NO;
    chiefDelphiButton.backgroundColor = [UIColor colorWithRed:253/255.0 green:136/255.0 blue:37/255.0 alpha:1.0];
    [chiefDelphiButton setShowsTouchWhenHighlighted:YES];
    [chiefDelphiButton setImage:[UIImage imageNamed:@"chiefdelphi-white"] forState:UIControlStateNormal];
    chiefDelphiButton.tag = TBASocialButtonContainerButtonTypeChiefDelphi;
    [chiefDelphiButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:chiefDelphiButton];
    
    NSArray *viewsArray = @[websiteButton, twitterButton, youtubeButton, chiefDelphiButton];
    
    // Setup constraints
    [viewsArray autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:0 alignment:NSLayoutFormatAlignAllCenterY];
    for (UIView *view in viewsArray) {
        [view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
@end
