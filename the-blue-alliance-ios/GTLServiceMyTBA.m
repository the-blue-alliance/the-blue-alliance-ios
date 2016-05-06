//
//  GTLServiceMyTBA.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "GTLServiceMyTBA.h"
#import "GTMHTTPFetcher.h"

@implementation GTLServiceMyTBA

+ (instancetype)sharedService {
    static GTLServiceMyTBA *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.retryEnabled = YES;
        self.apiVersion = @"v1";

        // From discovery.  Where to send JSON-RPC.
        // Turn off prettyPrint for this service to save bandwidth (especially on
        // mobile). The fetcher logging will pretty print.
        // self.rpcURL = [NSURL URLWithString:@"https://tbatv-prod-hrd.appspot.com/_ah/api/rpc?prettyPrint=false"];
//        self.rpcURL = [NSURL URLWithString:@"https://tbatv-prod-hrd.appspot.com/_ah/api/tbaMobile/v9/"];
//        self.rpcURL = [NSURL URLWithString:@"https://tbatv-prod-hrd.appspot.com/_ah/api/tbaMobile/v9/favorites/list"];
        self.rpcURL = [NSURL URLWithString:@"https://tba-dev-phil.appspot.com/_ah/api/tbaMobile/v9/favorites/list"];
        // [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return self;
}

@end
