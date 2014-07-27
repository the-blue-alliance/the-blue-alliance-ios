//
//  EventWebcastsViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/21/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventWebcastsViewController.h"
#import "Media.h"

@interface EventWebcastsViewController ()

@end

@implementation EventWebcastsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSSet *medias = self.event.media;
    UIScrollView *scroll = [[UIScrollView alloc] initForAutoLayout];
    [self.view addSubview:scroll];
    [scroll autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIView *previousVideoView = nil;
    for (Media *media in medias) {
        UILabel *titleLabel = [[UILabel alloc] initForAutoLayout];
        titleLabel.text = media.title;
        titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [scroll addSubview:titleLabel];
        [titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        if(previousVideoView) {
            [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousVideoView withOffset:40];
        } else {
            [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
        }
        
        UIWebView *videoEmbed = [[UIWebView alloc] initForAutoLayout];
        [scroll addSubview:videoEmbed];
        [videoEmbed autoConstrainAttribute:ALDimensionWidth toAttribute:ALDimensionHeight ofView:videoEmbed withMultiplier:(1280.0/720.0)]; // Just a ballbark figure
        [videoEmbed autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [videoEmbed autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:8];
        [videoEmbed autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:8];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.url]];
        [videoEmbed loadRequest:request];
        
        
        previousVideoView = videoEmbed;
    }
    
    [previousVideoView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4];
}

@end
