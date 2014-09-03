//
//  MediaCollectionViewCell.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "MediaCollectionViewCell.h"
#import <AsyncImageView/AsyncImageView.h>

@interface MediaCollectionViewCell () <UIWebViewDelegate>
@property (nonatomic, strong) AsyncImageView *imageView;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation MediaCollectionViewCell

- (AsyncImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[AsyncImageView alloc] initForAutoLayout];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        [_imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    return _imageView;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initForAutoLayout];
        _webView.contentMode = UIViewContentModeScaleAspectFit;
//        _webView.scalesPageToFit = YES;
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
        [self addSubview:_webView];
        [_webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    return _webView;
}



- (void)webViewDidStartLoad:(UIWebView *)webView
{
	
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//	CGSize contentSize = webView.scrollView.contentSize;
//    CGSize viewSize = webView.bounds.size;
//    
//    float scale = viewSize.width / contentSize.width;
//    if (scale < 0.9) {
//        NSLog(@"Zoom out fix for web view: %f", scale);
//        
//        webView.scrollView.minimumZoomScale = scale;
//        webView.scrollView.maximumZoomScale = scale;
//        webView.scrollView.zoomScale = scale;
//    }
//}


- (void)setMedia:(Media *)media
{
    _media = media;
    
    if([media.type isEqualToString:@"cdphotothread"]) {
        self.imageView.hidden = NO;
        self.webView.hidden = YES;
        [self.webView stopLoading];
        
        self.imageView.imageURL = [NSURL URLWithString:media.url];
    } else {
        self.imageView.hidden = YES;
        self.webView.hidden = NO;
        self.imageView.imageURL = nil;
        
        if([media.type isEqualToString:@"youtube"]) {
            CGSize insetSize = CGSizeMake(self.bounds.size.width - 16, self.bounds.size.height - 16);
            NSString *html = [media youtubeVideoEmbedHTMLForSize:insetSize];
            [self.webView loadHTMLString:html baseURL:nil];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.url]];
            [self.webView loadRequest:request];
        }
    }
}

@end
