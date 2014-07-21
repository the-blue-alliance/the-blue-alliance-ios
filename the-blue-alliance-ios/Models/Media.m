//
//  Media.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Media.h"


@implementation Media

- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context
                withUserInfo:(id)userInfo
{
    
    self.key = info[@"key"];
    self.type = info[@"type"];
    
    if([self.type isEqualToString:@"youtube"])
    {
        self.title = @"YouTube";
        self.url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.key];
    }
    else if([self.type isEqualToString:@"tba"])
    {
        self.title = @"TBA";
        self.url = info[@"key"];
    }
    else if([self.type isEqualToString:@"ustream"])
    {
        self.title = @"Ustream";
        self.channel = info[@"channel"];
        self.url = [NSString stringWithFormat:@"http://www.ustream.tv/channel/%@", self.channel];
    }
    else if([self.type isEqualToString:@"twitch"])
    {
        self.title = [NSString stringWithFormat:@"Twitch - %@", info[@"channel"]];
        self.channel = info[@"channel"];
        self.url = [NSString stringWithFormat:@"http://www.twitch.tv/%@", self.channel];
    }
    else if([self.type isEqualToString:@"justin"])
    {
        self.title = [NSString stringWithFormat:@"Justin - %@", info[@"channel"]];
        self.channel = info[@"channel"];
        self.url = [NSString stringWithFormat:@"http://www.justin.tv/%@", self.channel];
    }
    else if([self.type isEqualToString:@"iframe"])
    {
        self.title = @"Webcast";
        NSString *url = [info[@"file"] stringByReplacingOccurrencesOfString:@"<iframe src=\"" withString:@""];
        NSRange quoteLoc = [url rangeOfString:@"\""];
        self.url = [url substringToIndex:quoteLoc.location];
    }
    else if([self.type isEqualToString:@"livestream"])
    {
        self.title = @"Livestream";
        // http://new.livestream.com/accounts/{{webcast.channel}}/events/{{webcast.file}}/player?width=640&height=360&autoPlay=true&mute=false
        self.channel = info[@"channel"];
        self.url = [NSString stringWithFormat:@"http://new.livestream.com/accounts/%@/events/%@", info[@"channel"], info[@"file"]];
    }
    else if([self.type isEqualToString:@"rtmp"])
    {
        self.title = @"Webcast";
        self.channel = info[@"channel"];
        self.url = [NSString stringWithFormat:@"rtmp://%@%@", info[@"channel"], info[@"file"]];
    }
    else if([self.type isEqualToString:@"mms"])
    {
        self.title = @"Webcast";
        self.channel = info[@"channel"];
        self.url = info[@"channel"];
    }
    else
    {
        [NSException raise:@"Unimplemented media type!" format:@"Media type %@ has not be implemented yet! (implement me pl0x)", self.type];
    }
}

@end
