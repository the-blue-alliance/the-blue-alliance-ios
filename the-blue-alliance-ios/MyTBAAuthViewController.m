//
//  MyTBAAuthViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBAAuthViewController.h"
#import "MyTBAAuthHelper.h"
#import "MyTBAAuthenticaion.h"

@interface MyTBAAuthViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *webViewActivityIndicator;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) MyTBAAuthHelper *oAuthHelper;

@end

@implementation MyTBAAuthViewController

#pragma mark - Properities

- (MyTBAAuthHelper *)oAuthHelper {
    if (!_oAuthHelper) {
        _oAuthHelper = [[MyTBAAuthHelper alloc] init];
    }
    return _oAuthHelper;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.webView loadRequest:[self.oAuthHelper generateAuthRequest]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.title = @"Sign In with Google";
}

#pragma mark - UI Actions

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)connectionFailedWithError:(NSError *)error {
    [self.webViewActivityIndicator setHidden:YES];
    
    if (self.authFailed) {
        self.authFailed(error);
    }
}

#pragma mark - <UIWebViewDelegate> Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *currentUrl = request.URL.absoluteString;
    
    if (currentUrl && ([currentUrl rangeOfString:self.oAuthHelper.redirectUrl].location == 0)) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:currentUrl];
        if (!urlComponents.query) {
            return YES;
        }
        
        // Split query items in to name/value pairs
        NSMutableArray *queryItemPairs = [[NSMutableArray alloc] init];
        for (NSString *queryItem in [urlComponents.query componentsSeparatedByString:@"&"]) {
            NSArray *queryItemParts = [queryItem componentsSeparatedByString:@"="];
            if (queryItemParts.count > 1) {
                [queryItemPairs addObject:@{@"name": [queryItemParts objectAtIndex:0], @"value": [queryItemParts objectAtIndex:1]}];
            }
        }
        
        // Grab the code query item
        NSString *authCode = nil;
        for (NSDictionary *item in queryItemPairs) {
            if ([[item objectForKey:@"name"] isEqualToString:@"code"]) {
                authCode = [item objectForKey:@"value"];
            }
        }

        if (authCode) {
            [self.oAuthHelper getAuthenticationForCode:authCode withCompletionBlock:^(NSError *error) {
                if (error) {
                    if (self.authFailed) {
                        self.authFailed(error);
                    }
                } else {
                    if (self.authSucceeded) {
                        self.authSucceeded();
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    [self.webViewActivityIndicator setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webViewActivityIndicator setHidden:YES];
}


- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [self.webViewActivityIndicator setHidden:YES];
}

@end
