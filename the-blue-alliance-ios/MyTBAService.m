//
//  GTLServiceMyTBA.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBAService.h"
#import "MyTBAAuthenticaion.h"
#import "Valet.h"
#import "MyTBAAuthHelper.h"
#import "TBAFavorite.h"

static NSString *const MyTBARootURL     = @"https://tba-dev-phil.appspot.com/_ah/api/";
static NSString *const MyTBAServicePath = @"tbaMobile/v9/";
static NSString *const MyTBAKeychainKey = @"myTBAKeychainItem";
static NSString *const EtagKey          = @"ETAG:";

#define kErrorDomain    @"com.the-blue-alliance.MyTBA.ErrorDomain"

@interface MyTBAService () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) VALValet *keychainValet;
@property (nonatomic, strong) MyTBAAuthHelper *authHelper;

@end

@interface MyTBARequestWrapper : NSObject

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic, copy) MyTBARequestCompletionBlock completionHandler;

@end

@implementation MyTBAService
@synthesize authentication = _authentication;

#pragma mark - Class Methods

+ (instancetype)sharedService {
    static MyTBAService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requests = [[NSMutableDictionary alloc] init];
        self.keychainValet = [[VALValet alloc] initWithIdentifier:@"MyTBA" accessibility:VALAccessibilityAlways];
        self.authHelper = [[MyTBAAuthHelper alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (void)setAuthentication:(MyTBAAuthenticaion *)authentication {
    _authentication = authentication;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authentication];
    [self.keychainValet setObject:data forKey:MyTBAKeychainKey];
}

- (MyTBAAuthenticaion *)authentication {
    if (!_authentication) {
        NSData *data = [self.keychainValet objectForKey:MyTBAKeychainKey];
        if (data) {
            _authentication = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return _authentication;
}

- (NSURLSession *)urlSession {
    if (_urlSession == nil) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:nil];
    }
    
    return _urlSession;
}

#pragma mark - Public Methods

- (void)removeAuthentication {
    _authentication = nil;

    [self.keychainValet removeObjectForKey:MyTBAKeychainKey];
}

- (NSUInteger)fetchFavorites:(void (^)(NSArray<TBAFavorite *> *favorites, NSError *error))completion {
    return [self callApiMethod:@"favorites/list" andCompletionHandler:^(NSURLResponse *response, id parsedData, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        } else if (parsedData) {
            if (parsedData[@"favorites"] && [parsedData[@"favorites"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *favorites = [[NSMutableArray alloc] init];
                for (NSDictionary *favoriteDictionary in parsedData[@"favorites"]) {
                    [favorites addObject:[[TBAFavorite alloc] initWithServerResponse:favoriteDictionary]];
                }
                completion(favorites, nil);
            } else {
                // No favorites
                completion(nil, nil);
            }
        }
    }];
}

#pragma mark - Private Methods

- (NSString *)etagForURL:(NSURL *)url {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", EtagKey, url.description];
    return [[NSUserDefaults standardUserDefaults] stringForKey:urlString];
}

- (void)setEtag:(NSString *)etag forURL:(NSURL *)url {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", EtagKey, url.description];
    [[NSUserDefaults standardUserDefaults] setObject:etag forKey:urlString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)callApiMethod:(NSString *)aMethod andCompletionHandler:(TBAKitRequestCompletionBlock)aHandler  {
    if (self.authentication == nil) {
        NSError *error = [self errorWithCode:TBAKitErrorCodeInvalidIDHeader andDescription:@"Invalid ID Header"];
        
        if (aHandler) {
            aHandler(nil, nil, error);
        }
        
        return 0;
    }
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", MyTBARootURL, MyTBAServicePath]];
    NSURL *requestURL = [[NSURL alloc] initWithString:aMethod relativeToURL:baseURL];
    
    NSString *etag = [self etagForURL:requestURL.absoluteURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:15.0f];
    request.HTTPMethod = @"POST";
    
    NSString *accessToken;
    if (self.authentication.expired) {
        NSLog(@"Expired... Refreshing token");
        [self.authHelper refreshAuthentication:self.authentication withCompletionBlock:^(NSError *error) {
            if (error) {
                NSLog(@"Error refreshing token!");
                if (aHandler) {
                    aHandler(nil, nil, error);
                }
            } else {
                NSLog(@"Token refreshed");
                // This isn't passing back up an integer... need to work on that
                [self callApiMethod:aMethod andCompletionHandler:aHandler];
            }
        }];
    } else {
        accessToken = self.authentication.accessToken;
    }
    if (!accessToken) {
        return 0;
    }
    
    [request setValue:[NSString stringWithFormat:@"%@ %@", self.authentication.tokenType, accessToken] forHTTPHeaderField:@"Authorization"];

    if (etag) {
        [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
    }
 
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request];
    
    MyTBARequestWrapper *requestWrapper = [[MyTBARequestWrapper alloc] init];
    
    requestWrapper.dataTask = dataTask;
    requestWrapper.completionHandler = aHandler;
    
    [dataTask resume];
    
    (self.requests)[@(dataTask.taskIdentifier)] = requestWrapper;
    
    return dataTask.taskIdentifier;
}

- (void)cancelRequestWithIdentifier:(NSUInteger)identifier {
    MyTBARequestWrapper *requestWrapper = (self.requests)[@(identifier)];
    [requestWrapper.dataTask cancel];
    
    [self.requests removeObjectForKey:@(identifier)];
}

#pragma mark - <NSURLSessionTaskDelegate> Methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    MyTBARequestWrapper *requestWrapper = (self.requests)[@(dataTask.taskIdentifier)];
    [requestWrapper.receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)sessionError {
    MyTBARequestWrapper *requestWrapper = (self.requests)[@(task.taskIdentifier)];

    NSError *error = nil;
    id parsedData = nil;
    
    if (sessionError) {
        error = sessionError;
    } else {
        // CHECK IF WE HAVE TO HANDLE 304's HERE
        parsedData = [NSJSONSerialization JSONObjectWithData:requestWrapper.receivedData
                                                     options:0
                                                       error:&error];
        
        if (parsedData) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *headerFields = response.allHeaderFields;
            NSString *etag = headerFields[@"Etag"];
            
            if (etag) {
                [self setEtag:etag forURL:task.originalRequest.URL];
            }
        } else if (!error) {
            error = [self errorWithCode:TBAKitErrorCodeJSONParsingFailed andDescription:@"JSON Parsing Failed."];
        }
    }
    
    if (requestWrapper.completionHandler) {
        requestWrapper.completionHandler(task.response, parsedData, error);
    }
    
    [self.requests removeObjectForKey:@(task.taskIdentifier)];
}


#pragma mark - Private Methods

- (NSMutableData *)encodeRequestParams:(NSDictionary *)params {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

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

@implementation MyTBARequestWrapper

- (id)init {
    if (self = [super init]) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    return self;
}

@end
