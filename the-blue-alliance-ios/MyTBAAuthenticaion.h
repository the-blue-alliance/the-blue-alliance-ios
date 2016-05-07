//
//  MyTBAAuthenticaion.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyTBAAuthenticaion : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idToken;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *tokenType;

@property (readonly) BOOL expired;

- (instancetype)initWithServerResponse:(NSDictionary *)response;
- (void)updateWithResponse:(NSDictionary *)response;

@end
