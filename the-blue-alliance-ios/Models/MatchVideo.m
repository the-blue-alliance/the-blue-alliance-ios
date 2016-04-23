//
//  MatchVideo.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "MatchVideo.h"
#import "Match.h"

@implementation MatchVideo

@dynamic key;
@dynamic videoType;
@dynamic match;

+ (instancetype)insertMatchVideoWithModelMatchVideo:(TBAMatchVideo *)modelMatchVideo forMatch:(Match *)match inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelMatchVideo.key];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(MatchVideo *matchVideo) {
        matchVideo.key = modelMatchVideo.key;
        matchVideo.videoType = @(modelMatchVideo.type);
        matchVideo.match = match;
    }];
}

+ (NSArray *)insertMatchVidoesWithModelMatchVidoes:(NSArray<TBAMatchVideo *> *)modelMatchVidoes forMatch:(Match *)match inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMatchVideo *matchVideo in modelMatchVidoes) {
        [arr addObject:[self insertMatchVideoWithModelMatchVideo:matchVideo forMatch:match inManagedObjectContext:context]];
    }
    return arr;
}

- (NSURL *)videoUrl {
    NSString *url;
    switch ([self.videoType integerValue]) {
        case MatchVideoTypeYouTube:
            url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.key];
            break;
        case MatchVideoTypeTBA:
            url = self.key;
            break;
        default:
            break;
    }
    return [NSURL URLWithString:url];
}

@end
