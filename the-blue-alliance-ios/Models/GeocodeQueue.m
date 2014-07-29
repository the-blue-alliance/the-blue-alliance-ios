//
//  GeocodeQueue.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/27/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "GeocodeQueue.h"

@interface GeocodeQueue ()
@property (nonatomic, strong) NSMutableArray *geocodeQueue;

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSMutableDictionary *geocodeCache;
@end

@implementation GeocodeQueue

- (NSMutableArray *)geocodeQueue
{
    if(!_geocodeQueue) {
        _geocodeQueue = [[NSMutableArray alloc] init];
    }
    return _geocodeQueue;
}

- (NSMutableDictionary *)geocodeCache
{
    if(!_geocodeCache) {
        _geocodeCache = [[NSMutableDictionary alloc] init];
    }
    return _geocodeCache;
}

- (CLGeocoder *)geocoder
{
    if(!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

+ (instancetype)sharedGeocodeQueue
{
    static GeocodeQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[self alloc] init];
    });
    return sharedQueue;
}


#define GEOCODE_TEXT_KEY @"text"
#define GEOCODE_CALLBACK_KEY @"callback"
- (void)addTextToGeocodeQueue:(NSString *)text withCallback:(CLGeocodeCompletionHandler)callback
{
    NSDictionary *requestDict = @{GEOCODE_TEXT_KEY: text, GEOCODE_CALLBACK_KEY: callback};
    [self.geocodeQueue addObject:requestDict];

    if(!self.geocoder.isGeocoding) {
        [self geocodeNextRequest];
    }
}

- (void)geocodeNextRequest
{
    NSDictionary *request = [self.geocodeQueue firstObject];
    if(!request) {
        return;
    }
    
    if(self.geocodeCache[request[GEOCODE_TEXT_KEY]]) {
        NSArray *placemarks = self.geocodeCache[request[GEOCODE_TEXT_KEY]];
        NSLog(@"Geocoded %@ FROM CACHE!", request[GEOCODE_TEXT_KEY]);
        NSLog(@"%ld remaining...", (long)self.geocodeQueue.count);
        
        [self.geocodeQueue removeObject:request];
        ((CLGeocodeCompletionHandler)request[GEOCODE_CALLBACK_KEY])(placemarks, nil);
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self geocodeNextRequest];
//        });
    }
    
    __weak GeocodeQueue *weakSelf = self;
    [self.geocoder geocodeAddressString:request[GEOCODE_TEXT_KEY] completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Geocoded %@", request[GEOCODE_TEXT_KEY]);
        NSLog(@"%ld remaining...", (long)self.geocodeQueue.count);
        
        if(placemarks) {
            self.geocodeCache[request[GEOCODE_TEXT_KEY]] = placemarks;
        }
        
        double pause = 0;
        BOOL rateLimitError = error.code == kCLErrorNetwork;
        if(!rateLimitError) {
            [weakSelf.geocodeQueue removeObject:request];
            pause = 1;
        } else {
            pause = 30;
        }
        
        ((CLGeocodeCompletionHandler)request[GEOCODE_CALLBACK_KEY])(placemarks, error);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pause * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf geocodeNextRequest];
        });
    }];
}

@end
