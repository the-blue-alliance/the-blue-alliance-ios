//
//  MatchVideo.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, MatchVideoType) {
    MatchVideoTypeYouTube,
    MatchVideoTypeTBA
};

@class Match;

NS_ASSUME_NONNULL_BEGIN

@interface MatchVideo : NSManagedObject

+ (instancetype)insertMatchVideoWithModelMatchVideo:(TBAMatchVideo *)modelMatchVideo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchVidoesWithModelMatchVidoes:(NSArray<TBAMatchVideo *> *)modelMatchVidoes inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSURL *)videoUrl;

@end

NS_ASSUME_NONNULL_END

#import "MatchVideo+CoreDataProperties.h"
