//
//  MyTBAAuthHelper.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBAAuthHelper.h"
#import "MyTBAAuthenticaion.h"
#import "MyTBAService.h"

static NSString *const MyTBAScope       = @"https://www.googleapis.com/auth/userinfo.email";
static NSString *const MyTBAClientID    = @"259024084762-alrj1fdklkqm268asaj6tv71u4cdae10.apps.googleusercontent.com";
static NSString *const MyTBAClientSecret = @"_YKJIos8bKGzFm7PDHeN5abQ";

static NSString *const AuthorizeURL   = @"https://accounts.google.com/o/oauth2/auth";
static NSString *const AccessTokenURL = @"https://accounts.google.com/o/oauth2/token";
static NSString *const RedirectURL    = @"https://tba-dev-phil.appspot.com/oauth2callback";

@interface MyTBAAuthHelper ()

@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation MyTBAAuthHelper

#pragma mark - Properities

- (NSString *)redirectUrl {
    return RedirectURL;
}

#pragma mark - Initilization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    }
    return self;
}

#pragma mark - Public Methods

- (NSURLRequest *)generateAuthRequest {
    NSString *url = [NSString stringWithFormat:@"%@?response_type=code&access_type=offline&approval_prompt=force&scope=%@&client_id=%@&redirect_uri=%@",
                     AuthorizeURL,
                     MyTBAScope,
                     MyTBAClientID,
                     RedirectURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    return request;
}

- (NSString *)userAgent {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *appID = [bundle bundleIdentifier];
    
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (version == nil) {
        version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    
    if (appID && version) {
        appID = [appID stringByAppendingFormat:@"/%@", version];
    }
    
    NSString *userAgent = @"gtm-oauth2";
    if (appID) {
        userAgent = [userAgent stringByAppendingFormat:@" %@", appID];
    }
    return userAgent;
}

- (void)getAuthenticationForCode:(NSString *)authCode withCompletionBlock:(void (^)(NSError *error))completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"grant_type=authorization_code&client_id=%@&client_secret=%@&code=%@&redirect_uri=%@",
                          MyTBAClientID,
                          MyTBAClientSecret,
                          authCode,
                          RedirectURL];
    [self oauthRequestWithPostBodyString:postBody withCompletionBlock:^(NSDictionary *json, NSError *error) {
        if (error) {
            completionBlock(error);
        } else {
            MyTBAAuthenticaion *auth = [[MyTBAAuthenticaion alloc] initWithServerResponse:json];
            [[MyTBAService sharedService] setAuthentication:auth];

            completionBlock(nil);
        }
    }];
}

- (void)refreshAuthentication:(MyTBAAuthenticaion *)auth withCompletionBlock:(void (^)(NSError *error))completionBlock {
    NSString *postBody = [NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@",
                          auth.refreshToken,
                          MyTBAClientID,
                          MyTBAClientSecret];
    
    [self oauthRequestWithPostBodyString:postBody withCompletionBlock:^(NSDictionary *json, NSError *error) {
        if (error) {
            completionBlock(error);
        } else {
            [auth updateWithResponse:json];
            [[MyTBAService sharedService] setAuthentication:auth];
            
            completionBlock(nil);
        }
    }];
}

- (void)oauthRequestWithPostBodyString:(NSString *)postBodyString withCompletionBlock:(void (^)(NSDictionary *json, NSError *error))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:AccessTokenURL]];
    [request setHTTPMethod:@"POST"];

    [request setHTTPBody:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *userAgent = [self userAgent];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [[self.urlSession dataTaskWithRequest:request
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            if (error) {
                                completionBlock(nil, error);
                                return;
                            }
                            
                            id jsonValue = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments
                                                                             error:&error];
                            
                            if (jsonValue && [jsonValue isKindOfClass:[NSDictionary class]]) {
                                completionBlock(jsonValue, nil);
                            } else {
                                completionBlock(nil, error);
                            }
                        }] resume];
}

@end
