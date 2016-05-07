//
//  MyTBAAuthHelper.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyTBAAuthenticaion;

@interface MyTBAAuthHelper : NSObject

@property (readonly) NSString *redirectUrl;

- (NSURLRequest *)generateAuthRequest;

- (void)getAuthenticationForCode:(NSString *)authCode withCompletionBlock:(void (^)(NSError *error))completionBlock;
- (void)refreshAuthentication:(MyTBAAuthenticaion *)auth withCompletionBlock:(void (^)(NSError *error))completionBlock;

@end
