//
//  TBAFavorite.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAFavorite.h"

@implementation TBAFavorite

- (void)updateFromServerResponse:(NSDictionary *)response {
    self.deviceKey = [self parseStringForKey:@"device_key" fromResponse:response];
    self.modelKey = [self parseStringForKey:@"model_key" fromResponse:response];
    self.modelType = [self parseNumberForKey:@"model_type" fromResponse:response];
}

@end
