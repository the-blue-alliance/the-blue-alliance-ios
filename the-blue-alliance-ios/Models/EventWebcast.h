//
//  EventWebcast.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
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

@interface EventWebcast : NSManagedObject

@property (nonatomic) int32_t type;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) Event *event;

+ (instancetype)insertEventWebcastWithModelEventWebcast:(TBAEventWebcast *)modelEventWebcast forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventWebcastsWithModelEventWebcasts:(NSArray *)modelEventWebcasts forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end
