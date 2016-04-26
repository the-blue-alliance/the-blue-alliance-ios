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
#import "TBARankingsViewController.h"
#import "TBAMatchesViewController.h"
#import "EventAlliancesViewController.h"
#import "EventDistrictPointsViewController.h"
#import "EventAwardsViewController.h"
#import "EventTeamViewController.h"
#import "Event.h"

static NSString *const InfoViewControllerEmbed      = @"InfoViewControllerEmbed";
static NSString *const TeamsViewControllerEmbed     = @"TeamsViewControllerEmbed";
static NSString *const RankingsViewControllerEmbed  = @"RankingsViewControllerEmbed";
static NSString *const MatchesViewControllerEmbed   = @"MatchesViewControllerEmbed";

static NSString *const AlliancesViewControllerSegue         = @"AlliancesViewControllerSegue";
static NSString *const DistrictPointsViewControllerSegue    = @"DistrictPointsViewControllerSegue";
static NSString *const StatsViewControllerSegue             = @"StatsViewControllerSegue";
static NSString *const AwardsViewControllerSegue            = @"AwardsViewControllerSegue";

static NSString *const EventTeamViewControllerSegue = @"EventTeamViewControllerSegue";


typedef NS_ENUM(NSInteger, TBAEventSegment) {
    TBAEventSegmentInfo = 0,
    TBAEventSegmentTeams,
    TBAEventSegmentRankings,
    TBAEventSegmentMatches,
};

@interface EventViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;
@property (nonatomic, weak) IBOutlet UIView *teamsView;

@property (nonatomic, strong) TBARankingsViewController *rankingsViewController;
@property (nonatomic, weak) IBOutlet UIView *rankingsView;

@property (nonatomic, strong) TBAMatchesViewController *matchesViewController;
@property (nonatomic, weak) IBOutlet UIView *matchesView;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
}

#pragma mark - Private Methods

- (void)cancelRefreshes {
    NSArray *refreshTVCs = @[self.infoViewController, self.teamsViewController, self.rankingsViewController, self.matchesViewController];
    for (TBARefreshTableViewController *refreshTVC in refreshTVCs) {
        if (refreshTVC) {
            [refreshTVC cancelRefresh];
        }
    }
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    self.navigationItem.title = [self.event friendlyNameWithYear:YES];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBAEventSegmentInfo) {
        [self showView:self.infoView];
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventSegmentTeams) {
        [self showView:self.teamsView];
        if (self.teamsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.teamsViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventSegmentRankings) {
        [self showView:self.rankingsView];
        if (self.rankingsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.rankingsViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventSegmentMatches) {
        [self showView:self.matchesView];
        if (self.matchesViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.matchesViewController.refresh();
        }
    }
}

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.infoView, self.teamsView, self.rankingsView, self.matchesView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
    [self updateInterface];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:InfoViewControllerEmbed]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.persistenceController = self.persistenceController;
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
        self.teamsViewController.persistenceController = self.persistenceController;
        self.teamsViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.teamsViewController.teamSelected = ^(Team *team){
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:team];
        };
    } else if ([segue.identifier isEqualToString:RankingsViewControllerEmbed]) {
        self.rankingsViewController = segue.destinationViewController;
        self.rankingsViewController.persistenceController = self.persistenceController;
        self.rankingsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:MatchesViewControllerEmbed]) {
        self.matchesViewController = segue.destinationViewController;
        self.matchesViewController.persistenceController = self.persistenceController;
        self.matchesViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:AlliancesViewControllerSegue]) {
        EventAlliancesViewController *eventAlliancesViewController = segue.destinationViewController;
        eventAlliancesViewController.persistenceController = self.persistenceController;
        eventAlliancesViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:AwardsViewControllerSegue]) {
        EventAwardsViewController *eventAwardsViewController = segue.destinationViewController;
        eventAwardsViewController.persistenceController = self.persistenceController;
        eventAwardsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:DistrictPointsViewControllerSegue]) {
        EventDistrictPointsViewController *eventDistrictPointsViewController = segue.destinationViewController;
        eventDistrictPointsViewController.persistenceController = self.persistenceController;
        eventDistrictPointsViewController.event = self.event;
    }
    // TODO: Add stats
    else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        Team *team = (Team *)sender;
        
        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.persistenceController = self.persistenceController;
        eventTeamViewController.event = self.event;
        eventTeamViewController.team = team;
    }
}

@end
