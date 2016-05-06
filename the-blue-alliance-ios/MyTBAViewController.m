//
//  MyTBAViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBAViewController.h"
#import "MyTBASignInViewController.h"
#import "TBAFavoritesViewController.h"
#import "TBASubscriptionsViewController.h"
#import "TBANotificationsViewController.h"
#import "GTLServiceMyTBA.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLQuery.h"
#import "TBAFavorite.h"

// Google Auth constants
static NSString *const MyTBAScope       = @"https://www.googleapis.com/auth/userinfo.email"; // scope for email
static NSString *const MyTBAKeychainKey = @"myTBAKeychainItem";
static NSString *const MyTBAClientID    = @"259024084762-oatcrduj4uf6hc0m6lko9pb82i71n9sb.apps.googleusercontent.com";

// Navigation contants
static NSString *const MyTBASignInEmbed = @"MyTBASignInEmbed";

/*
static NSString *const EventViewControllerSegue         = @"EventViewControllerSegue";
static NSString *const DistrictTeamViewControllerSegue  = @"DistrictTeamViewControllerSegue";
*/

@interface MyTBAViewController ()

@property (nonatomic, strong) MyTBASignInViewController *signInViewController;
@property (nonatomic, strong) IBOutlet UIView *signInView;

@property (nonatomic, strong) TBAFavoritesViewController *favoritesViewController;
@property (nonatomic, strong) IBOutlet UIView *favoritesView;

@property (nonatomic, strong) TBASubscriptionsViewController *subscriptionsViewController;
@property (nonatomic, strong) IBOutlet UIView *subscriptionsView;

@property (nonatomic, strong) TBANotificationsViewController *recentNotificationsViewController;
@property (nonatomic, strong) IBOutlet UIView *recentNotificationsView;

@end

@implementation MyTBAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Check if signed in, if not, show the other shit
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:MyTBAKeychainKey clientID:MyTBAClientID clientSecret:nil error:nil];
    if (auth) {
        self.signInView.hidden = YES;
        [[GTLServiceMyTBA sharedService] setAuthorizer:auth];
        [self queryForScoresList];
    } else {
        self.signInView.hidden = NO;
        [self.view bringSubviewToFront:self.signInView];
    }

//    self.refreshViewControllers = @[self.favoritesViewController, self.subscriptionsViewController, self.recentNotificationsViewController];
//    self.containerViews = @[self.favoritesView, self.subscriptionsView, self.recentNotificationsView];
    
    [self styleInterface];
}

- (void)queryForScoresList {
    NSString *methodName = @"favorites/list";
    GTLQuery *query = [GTLQuery queryWithMethodName:methodName];
    query.expectedObjectClass = [TBAFavorite class];
    [[GTLServiceMyTBA sharedService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Obj: %@", object);
    }];
}

#pragma mark - Interface Actions

- (void)styleInterface {
    self.navigationItem.title = @"myTBA";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 259024084762-oatcrduj4uf6hc0m6lko9pb82i71n9sb.apps.googleusercontent.com
    __weak typeof(self) weakSelf = self;
    if ([segue.identifier isEqualToString:MyTBASignInEmbed]) {
        self.signInViewController = segue.destinationViewController;
        self.signInViewController.signIn = ^() {
            GTMOAuth2ViewControllerTouch *authViewControlelr = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:MyTBAScope
                                                                                                          clientID:MyTBAClientID
                                                                                                      clientSecret:nil
                                                                                                  keychainItemName:MyTBAKeychainKey
                                                                                                          delegate:weakSelf
                                                                                                  finishedSelector:@selector(viewController:finishedWithAuth:error:)];
            
            [weakSelf presentViewController:authViewControlelr animated:YES completion:nil];
        };
    }
}


#pragma mark - Google Auth Sign In

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (error != nil) {
        NSLog(@"Auth error");
        // Authentication failed
        // Show an erro in here I suppose
    } else {
        NSLog(@"Auth succeeded");
        // Authentication succeeded
        [[GTLServiceMyTBA sharedService] setAuthorizer:auth];
        self.signInView.hidden = YES;
    }
}

@end
