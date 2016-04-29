//
//  MatchViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MatchViewController.h"
#import "TBARefreshTableViewController.h"
#import "TBAMatchViewController.h"
#import "TBAMatchBreakdownViewController.h"
#import "Match.h"
#import "Event.h"

static NSString *const MatchViewControllerEmbed             = @"MatchViewControllerEmbed";
static NSString *const MatchBreakdownViewControllerEmbed    = @"MatchBreakdownViewControllerEmbed";

@interface MatchViewController ()

@property (nonatomic, strong) TBAMatchViewController *matchViewController;
@property (nonatomic, strong) IBOutlet UIView *matchView;

@property (nonatomic, strong) TBAMatchBreakdownViewController *matchBreakdownViewController;
@property (nonatomic, strong) IBOutlet UIView *matchBreakdownView;

@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.matchViewController, self.matchBreakdownViewController];
    self.containerViews = @[self.matchView, self.matchBreakdownView];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [self.match shortCompLevelString], self.match.matchNumber];
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.match.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MatchViewControllerEmbed]) {
        self.matchViewController = segue.destinationViewController;
        self.matchViewController.match = self.match;
    } else if ([segue.identifier isEqualToString:MatchBreakdownViewControllerEmbed]) {
        self.matchBreakdownViewController = segue.destinationViewController;
        self.matchBreakdownViewController.match = self.match;
    }
}

@end
