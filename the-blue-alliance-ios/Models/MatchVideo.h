//
//  MatchVideo.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

typedef NS_ENUM(NSInteger, MatchVideoType) {
    MatchVideoTypeYouTube,
    MatchVideoTypeTBA
};

@class Match;

NS_ASSUME_NONNULL_BEGIN

@interface MatchVideo : TBAManagedObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSNumber *videoType;
@property (nonatomic, retain) Match *match;

+ (instancetype)insertMatchVideoWithModelMatchVideo:(TBAMatchVideo *)modelMatchVideo forMatch:(Match *)match inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchVidoesWithModelMatchVidoes:(NSArray<TBAMatchVideo *> *)modelMatchVidoes forMatch:(Match *)match inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSURL *)videoUrl;

@end

NS_ASSUME_NONNULL_END
