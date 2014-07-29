//
//  GeocodeQueue.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/27/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface GeocodeQueue : NSObject

+ (instancetype)sharedGeocodeQueue;

- (void)addTextToGeocodeQueue:(NSString *)text withCallback:(CLGeocodeCompletionHandler)callback;

@end
