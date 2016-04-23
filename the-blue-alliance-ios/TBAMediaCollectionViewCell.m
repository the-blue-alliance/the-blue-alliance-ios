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

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation TBAMediaCollectionViewCell

- (void)awakeFromNib {
    self.imageView.hidden = YES;

    self.activityView.hidden = NO;
}

- (void)setMedia:(Media *)media {
    _media = media;
    [self.activityView startAnimating];
    
    NSURLRequest *request;
    if ([media.mediaType integerValue] == TBAMediaTypeCDPhotoThread) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.chiefdelphi.com/media/img/%@", media.imagePartial]];
        request = [NSURLRequest requestWithURL:url];
    } else if (media.mediaType == TBAMediaTypeYouTube) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://img.youtube.com/vi/%@/maxresdefault.jpg", media.foreignKey]];
        request = [NSURLRequest requestWithURL:url];
    }
    
    if (request) {
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error loading photo");
                // TODO: Show some temp photo in here
                return;
            }
            if (self.imageLoadedFromWeb) {
                self.imageLoadedFromWeb();
            }
            [self.imageView setImage:[UIImage imageWithData:data]];
            [self.activityView stopAnimating];
            
            self.activityView.hidden = YES;
            self.imageView.hidden = NO;
        }] resume];
    }
}

@end
