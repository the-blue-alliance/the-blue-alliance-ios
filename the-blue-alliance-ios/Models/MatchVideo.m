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

+ (instancetype)insertMatchVideoWithModelMatchVideo:(TBAMatchVideo *)modelMatchVideo inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchVideo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelMatchVideo.key];
    [fetchRequest setPredicate:predicate];
    
    MatchVideo *matchVideo;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        matchVideo = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (MatchVideo *mv in existingObjs) {
            [context deleteObject:mv];
        }
    }
    
    if (matchVideo == nil) {
        matchVideo = [NSEntityDescription insertNewObjectForEntityForName:@"MatchVideo" inManagedObjectContext:context];
    }
    
    matchVideo.key = modelMatchVideo.key;
    matchVideo.videoType = @(modelMatchVideo.type);
    
    return matchVideo;
}

+ (NSArray *)insertMatchVidoesWithModelMatchVidoes:(NSArray<TBAMatchVideo *> *)modelMatchVidoes inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMatchVideo *matchVideo in modelMatchVidoes) {
        [arr addObject:[self insertMatchVideoWithModelMatchVideo:matchVideo inManagedObjectContext:context]];
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
