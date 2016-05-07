//
//  GTLServiceMyTBA.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyTBAAuthenticaion;

typedef void (^MyTBARequestCompletionBlock)(NSURLResponse *response, id parsedData, NSError *error);

@interface MyTBAService : NSObject

@property (readonly) MyTBAAuthenticaion *authentication;

+ (instancetype)sharedService;

- (BOOL)setAuthenticaion:(MyTBAAuthenticaion *)auth;
- (BOOL)removeAuthentication;

@end
