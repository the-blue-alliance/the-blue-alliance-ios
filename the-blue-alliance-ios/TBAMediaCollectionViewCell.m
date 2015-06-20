//
//  TBAMediaCollectionViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/14/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMediaCollectionViewCell.h"
#import "TBAMedia.h"
#import "Media.h"

@interface TBAMediaCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation TBAMediaCollectionViewCell

- (void)awakeFromNib {
    self.imageView.hidden = YES;

    self.activityView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityView startAnimating];
    });
}

- (void)setMedia:(Media *)media {
    _media = media;

    NSURLRequest *request;
    if (media.cachedData) {
        [self.imageView setImage:[UIImage imageWithData:media.cachedData]];
        
        self.activityView.hidden = YES;
        self.imageView.hidden = NO;
    } else if (media.mediaTypeValue == TBAMediaTypeCDPhotoThread) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.chiefdelphi.com/media/img/%@", media.imagePartial]];
        request = [NSURLRequest requestWithURL:url];
    } else if (media.mediaTypeValue == TBAMediaTypeYouTube) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", media.foreignKey]];
        request = [NSURLRequest requestWithURL:url];
    }
    
    if (request) {
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError) {
                                       NSLog(@"Error loading photo");
                                       // TODO: Show some temp photo in here
                                       return;
                                   }
                                   media.cachedData = data;
                                   if (self.imageLoadedFromWeb) {
                                       self.imageLoadedFromWeb();
                                   }
                                   [self.imageView setImage:[UIImage imageWithData:data]];
                                   
                                   self.activityView.hidden = YES;
                                   self.imageView.hidden = NO;
                               }];
    }
}

@end
