//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 4/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAInfoViewController.h"
#import "TBATeamsViewController.h"
#import "TBAEventRankingsViewController.h"
#import "TBAMatchesViewController.h"
#import "EventAlliancesViewController.h"
#import "EventDistrictPointsViewController.h"
#import "EventAwardsViewController.h"
#import "EventTeamViewController.h"
#import "EventStatsViewController.h"
#import "MatchViewController.h"
#import "Team.h"
#import "Event.h"
#import "EventRanking.h"

static NSString *const InfoViewControllerEmbed      = @"InfoViewControllerEmbed";
static NSString *const TeamsViewControllerEmbed     = @"TeamsViewControllerEmbed";
static NSString *const RankingsViewControllerEmbed  = @"RankingsViewControllerEmbed";
static NSString *const MatchesViewControllerEmbed   = @"MatchesViewControllerEmbed";

static NSString *const AlliancesViewControllerSegue         = @"AlliancesViewControllerSegue";
static NSString *const DistrictPointsViewControllerSegue    = @"DistrictPointsViewControllerSegue";
static NSString *const StatsViewControllerSegue             = @"StatsViewControllerSegue";
static NSString *const AwardsViewControllerSegue            = @"AwardsViewControllerSegue";
static NSString *const MatchViewControllerSegue             = @"MatchViewControllerSegue";

static NSString *const EventTeamViewControllerSegue = @"EventTeamViewControllerSegue";

@interface EventViewController ()

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, strong) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;
@property (nonatomic, strong) IBOutlet UIView *teamsView;

@property (nonatomic, strong) TBAEventRankingsViewController *rankingsViewController;
@property (nonatomic, strong) IBOutlet UIView *rankingsView;

@property (nonatomic, strong) TBAMatchesViewController *matchesViewController;
@property (nonatomic, strong) IBOutlet UIView *matchesView;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.infoViewController, self.teamsViewController, self.rankingsViewController, self.matchesViewController];
    self.containerViews = @[self.infoView, self.teamsView, self.rankingsView, self.matchesView];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = [self.event friendlyNameWithYear:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:InfoViewControllerEmbed]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.infoViewController.showAlliances = ^{
            [weakSelf performSegueWithIdentifier:AlliancesViewControllerSegue sender:nil];
        };
        self.infoViewController.showDistrictPoints = ^{
            [weakSelf performSegueWithIdentifier:DistrictPointsViewControllerSegue sender:nil];
        };
        self.infoViewController.showStats = ^{
            [weakSelf performSegueWithIdentifier:StatsViewControllerSegue sender:nil];
        };
        self.infoViewController.showAwards = ^{
            [weakSelf performSegueWithIdentifier:AwardsViewControllerSegue sender:nil];
        };
    } else if ([segue.identifier isEqualToString:TeamsViewControllerEmbed]) {
        self.teamsViewController = segue.destinationViewController;
        self.teamsViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.teamsViewController.teamSelected = ^(Team *team){
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:team];
        };
    } else if ([segue.identifier isEqualToString:RankingsViewControllerEmbed]) {
        self.rankingsViewController = segue.destinationViewController;
        self.rankingsViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.rankingsViewController.rankingSelected = ^(id ranking) {
            EventRanking *eventRanking = (EventRanking *)ranking;
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:eventRanking];
        };
    } else if ([segue.identifier isEqualToString:MatchesViewControllerEmbed]) {
        self.matchesViewController = segue.destinationViewController;
        self.matchesViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.matchesViewController.matchSelected = ^(Match *match) {
            [weakSelf performSegueWithIdentifier:@"MatchViewControllerSegue" sender:match];
        };
    } else if ([segue.identifier isEqualToString:AlliancesViewControllerSegue]) {
        EventAlliancesViewController *eventAlliancesViewController = segue.destinationViewController;
        eventAlliancesViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:AwardsViewControllerSegue]) {
        EventAwardsViewController *eventAwardsViewController = segue.destinationViewController;
        eventAwardsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:DistrictPointsViewControllerSegue]) {
        EventDistrictPointsViewController *eventDistrictPointsViewController = segue.destinationViewController;
        eventDistrictPointsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:StatsViewControllerSegue]) {
        EventStatsViewController *eventStatsViewController = segue.destinationViewController;
        eventStatsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.event = self.event;
        
        if ([sender isKindOfClass:[Team class]]) {
            Team *team = (Team *)sender;
            eventTeamViewController.team = team;
        } else if ([sender isKindOfClass:[EventRanking class]]) {
            EventRanking *eventRanking = (EventRanking *)sender;
            eventTeamViewController.team = eventRanking.team;
            eventTeamViewController.eventRanking = eventRanking;
        }
    } else if ([segue.identifier isEqualToString:MatchViewControllerSegue]) {
        Match *match = (Match *)sender;
        
        MatchViewController *matchViewController = segue.destinationViewController;
        matchViewController.match = match;
    }
}

@end
