//
//  TBAMediaView.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAMediaView.h"
#import "Media.h"

@interface TBAMediaView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation TBAMediaView

#pragma mark - Initilization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Properities

- (UIActivityIndicatorView *)loadingActivityIndicator {
    if (!_loadingActivityIndicator) {
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingActivityIndicator.hidesWhenStopped = YES;
        _loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _loadingActivityIndicator;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

- (void)setMedia:(Media *)media {
    _media = media;
    
    if (self.dataTask) {
        [self.dataTask cancel];
        self.dataTask = nil;
    }
    [self configureCell];
}

- (void)configureCell {
    if (!self.imageView.superview) {
        [self addSubview:self.imageView];
        
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [self addConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];
    }
    
    if (self.downloadedImage) {
        self.imageView.image = self.downloadedImage;
        return;
    }
    
    if (!self.loadingActivityIndicator.superview) {
        [self addSubview:self.loadingActivityIndicator];
        
        NSLayoutConstraint *centerHorizontallyConstraint = [NSLayoutConstraint constraintWithItem:self.loadingActivityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *centerVerticallyConstraint = [NSLayoutConstraint constraintWithItem:self.loadingActivityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraints:@[centerHorizontallyConstraint, centerVerticallyConstraint]];
    }
    
    [self.loadingActivityIndicator startAnimating];
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.chiefdelphi.com/media/img/%@", self.media.imagePartial]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    self.dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.loadingActivityIndicator stopAnimating];
        
        if (error) {
            NSLog(@"Error loading photo");
            // TODO: Show some temp photo in here
            return;
        } else {
            UIImage *image = [UIImage imageWithData:data];
            if (self.imageDownloaded) {
                self.imageDownloaded(image);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView setImage:image];
            });
        }
    }];
    [self.dataTask resume];
}

@end
