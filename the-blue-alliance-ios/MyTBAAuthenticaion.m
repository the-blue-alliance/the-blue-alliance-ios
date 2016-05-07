//
//  MyTBAAuthenticaion.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBAAuthenticaion.h"

@interface MyTBAAuthenticaion ()

@property (nonatomic, strong) NSDate *expirationDate;

@end

@implementation MyTBAAuthenticaion

#pragma mark - Properities

- (BOOL)expired {
    BOOL shouldRefresh;
    if (!self.expirationDate) {
        shouldRefresh = YES;
    } else {
        // We'll consider the token expired if it expires 60 seconds from now or earlier
        NSDate *expirationDate = self.expirationDate;
        NSTimeInterval timeToExpire = [expirationDate timeIntervalSinceNow];
        if (expirationDate == nil || timeToExpire < 60.0) {
            // access token has expired, or will in a few seconds
            shouldRefresh = YES;
        }
    }
    return shouldRefresh;
}

#pragma mark - Initilization

- (instancetype)initWithServerResponse:(NSDictionary *)response {
    self = [super init];
    if (self) {
        [self updateWithResponse:response];
    }
    return self;
}

- (void)updateWithResponse:(NSDictionary *)response {
    if (response[@"id_token"]) {
        self.idToken = response[@"id_token"];
    }
    if (response[@"access_token"]) {
        self.accessToken = response[@"access_token"];
    }
    if (response[@"refresh_token"]) {
        self.refreshToken = response[@"refresh_token"];
    }
    if (response[@"token_type"]) {
        self.tokenType = response[@"token_type"];
    }
    if (response[@"expires_in"]) {
        NSNumber *expiresIn = [NSNumber numberWithInteger:[response[@"expires_in"] integerValue]];
        
        unsigned long deltaSeconds = [expiresIn unsignedLongValue];
        if (deltaSeconds > 0) {
            // Make sure this is the right timezone we're working with for server stuff
            self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:deltaSeconds];
        }
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.idToken = [decoder decodeObjectForKey:@"idToken"];
        self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
        self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
        self.tokenType = [decoder decodeObjectForKey:@"tokenType"];
        self.expirationDate = [decoder decodeObjectForKey:@"expirationDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.idToken forKey:@"idToken"];
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeObject:self.tokenType forKey:@"tokenType"];
    [encoder encodeObject:self.expirationDate forKey:@"expirationDate"];
}

@end
