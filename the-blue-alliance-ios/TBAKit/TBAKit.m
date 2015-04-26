//
//  TBAKit.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAKit.h"


#define kLastModifiedString     @"LAST_MODIFIED:"
#define kIDHeader               @"the-blue-alliance:ios:v0.1"
#define kTBAAPIURL              @"http://www.thebluealliance.com/api/v2/"
#define kErrorDomain            @"com.the-blue-alliance.TBAImporter.ErrorDomain"


@interface TBAKit () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@interface TBARequestWrapper : NSObject

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic, copy) TBARequestCompletionBlock completionHandler;

@end

@implementation TBAKit

#pragma mark - Class Methods

+ (TBAKit *)sharedKit {
    static dispatch_once_t pred = 0;
    __strong static TBAKit *_sharedKit = nil;
    
    dispatch_once(&pred, ^{
        _sharedKit = [[self alloc] init];
    });
    
    return _sharedKit;
}


#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        self.requests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (NSURLSession *)urlSession {
    if (_urlSession == nil) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:nil];
    }
    
    return _urlSession;
}


#pragma mark - Request Methods

- (NSString *)lastModifiedForURL:(NSURL *)url {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kLastModifiedString, url.description];
    return [[NSUserDefaults standardUserDefaults] stringForKey:urlString];
}

- (void)setLastModified:(NSString *)lastModified forURL:(NSURL *)url {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kLastModifiedString, url.description];
    [[NSUserDefaults standardUserDefaults] setObject:lastModified forKey:urlString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)executeTBAV2Request:(NSString *)aMethod callback:(TBARequestCompletionBlock)callback {
#warning hey future zach don't push this for brandon xoxo past zach
//    NSURL *baseURL = [[NSURL alloc] initWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TBAApiURL"]];
    NSURL *baseURL = [[NSURL alloc] initWithString:kTBAAPIURL];
    NSURL *requestURL = [[NSURL alloc] initWithString:aMethod relativeToURL:baseURL];
    NSString *ifModifiedSince = [self lastModifiedForURL:requestURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:kIDHeader forHTTPHeaderField:@"X-TBA-App-Id"];
    if (ifModifiedSince) {
        [request setValue:ifModifiedSince forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request];
    
    TBARequestWrapper *requestWrapper = [[TBARequestWrapper alloc] init];
    
    requestWrapper.dataTask = dataTask;
    requestWrapper.completionHandler = callback;
    
    [dataTask resume];
    
    [self.requests setObject:requestWrapper forKey:[NSNumber numberWithUnsignedInteger:[dataTask taskIdentifier]]];
    
    return [dataTask taskIdentifier];
}

- (void)cancelRequestWithIdentifier:(NSUInteger)identifier {
    TBARequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:identifier]];
    [requestWrapper.dataTask cancel];
    
    [self.requests removeObjectForKey:[NSNumber numberWithUnsignedInteger:identifier]];
}


#pragma mark - <NSURLSessionTaskDelegate> Methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    TBARequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:[dataTask taskIdentifier]]];
    [requestWrapper.receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)sessionError {
    TBARequestWrapper *requestWrapper = [self.requests objectForKey:[NSNumber numberWithUnsignedInteger:[task taskIdentifier]]];
    
    NSError *error;
    id parsedData;
    
    if (sessionError) {
        error = sessionError;
    } else {
        parsedData = [NSJSONSerialization JSONObjectWithData:requestWrapper.receivedData
                                                     options:0
                                                       error:&error];
        
        if (parsedData) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *headerFields = [response allHeaderFields];
            NSString *lastModified = headerFields[@"Last-Modified"];
            
            if (lastModified) {
                [self setLastModified:lastModified forURL:task.originalRequest.URL];
            }
        } else if (!error) {
            error = [self errorWithCode:7332 andDescription:@"JSON Parsing Failed."];
        }
    }
    
    if (requestWrapper.completionHandler) {
        requestWrapper.completionHandler(parsedData, error);
    }
    
    [self.requests removeObjectForKey:[NSNumber numberWithUnsignedInteger:[task taskIdentifier]]];
}


#pragma mark - Private Methods

- (NSError *)errorWithCode:(NSInteger)code andDescription:(NSString *)description {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: description,
                               };
    
    NSError *error = [NSError errorWithDomain:kErrorDomain
                                         code:code
                                     userInfo:userInfo];
    
    return error;
}

@end


@implementation TBARequestWrapper

- (id)init {
    if (self = [super init]) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    return self;
}

@end
