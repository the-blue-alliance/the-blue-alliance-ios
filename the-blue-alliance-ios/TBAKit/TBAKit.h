//
//  TBAKit.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TBARequestCompletionBlock)(id objects, NSError *error);

@interface TBAKit : NSObject

+ (TBAKit *)sharedKit;

- (NSUInteger)executeTBAV2Request:(NSString *)aMethod callback:(TBARequestCompletionBlock)callback;
- (void)cancelRequestWithIdentifier:(NSUInteger)identifier;

@end

@interface TBAKit (InternalMethods)

- (NSError *)errorWithCode:(NSInteger)code andDescription:(NSString *)description;

@end
