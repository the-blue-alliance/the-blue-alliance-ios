//
//  EventWebcast.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, WebcastType) {
    WebcastTypeLivestream,
    WebcastTypeMMS,
    WebcastTypeRTMP,
    WebcastTypeTwitch,
    WebcastTypeUstream,
    WebcastTypeYoutube,
    WebcastTypeIFrame,
    WebcastTypeHTML5
};

@class Event;

NS_ASSUME_NONNULL_BEGIN

@interface EventWebcast : NSManagedObject

+ (instancetype)insertEventWebcastWithModelEventWebcast:(TBAEventWebcast *)modelEventWebcast forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventWebcastsWithModelEventWebcasts:(NSArray<TBAEventWebcast *> *)modelEventWebcasts forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "EventWebcast+CoreDataProperties.h"
