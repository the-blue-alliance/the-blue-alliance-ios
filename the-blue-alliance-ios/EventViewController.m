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
#import "TBAAlliancesViewController.h"
#import "TBAAwardsViewController.h"
#import "HMSegmentedControl.h"
#import <PureLayout/PureLayout.h>
#import "Event.h"
#import "EventRanking.h"
#import "Match.h"
#import "Event+Fetch.h"
#import "Team.h"
#import "Team+Fetch.h"

typedef NS_ENUM(NSInteger, TBAEventDataType) {
    TBAEventDataTypeInfo = 0,
    TBAEventDataTypeTeams,
    TBAEventDataTypeRankings,
    TBAEventDataTypeMatches,
    TBAEventDataTypeAlliances,
    TBAEventDataTypeStats,
    TBAEventDataTypeAwards,
    TBAEventDataTypeDistrictPoints
};

@interface EventViewController ()

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;
@property (nonatomic, weak) IBOutlet UIView *teamsView;

@property (nonatomic, strong) TBARankingsViewController *rankingsViewController;
@property (nonatomic, weak) IBOutlet UIView *rankingsView;

@property (nonatomic, strong) TBAMatchesViewController *matchesViewController;
@property (nonatomic, weak) IBOutlet UIView *matchesView;

@property (nonatomic, strong) TBAAlliancesViewController *alliancesViewController;
@property (nonatomic, strong) IBOutlet UIView *alliancesView;

// Need stats view controller :smile:

@property (nonatomic, strong) TBAAwardsViewController *awardsViewController;
@property (nonatomic, strong) IBOutlet UIView *awardsView;

@property (nonatomic, strong) TBARankingsViewController *districtPointsViewController;
@property (nonatomic, weak) IBOutlet UIView *districtPointsView;

@property (nonatomic, strong) NSArray<NSNumber *> *eventWeeks;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
}

#pragma mark - Private Methods

- (void)cancelRefreshes {
    NSArray *refreshTVCs = @[self.infoViewController, self.teamsViewController, self.rankingsViewController, self.matchesViewController, self.alliancesViewController, self.awardsViewController, self.districtPointsViewController];
    for (TBARefreshTableViewController *refreshTVC in refreshTVCs) {
        if (refreshTVC) {
            [refreshTVC cancelRefresh];
        }
    }
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [self.event friendlyNameWithYear:YES];
    [self setupSegmentedControl];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeInfo) {
        [self showView:self.infoView];
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeTeams) {
        [self showView:self.teamsView];
        if (self.teamsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.teamsViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeRankings) {
        [self showView:self.rankingsView];
        if (self.rankingsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.rankingsViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeMatches) {
        [self showView:self.matchesView];
        if (self.matchesViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.matchesViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeAlliances) {
        [self showView:self.alliancesView];
        if (self.alliancesViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.alliancesViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeAwards) {
        [self showView:self.awardsView];
        if (self.awardsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.awardsViewController.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeDistrictPoints) {
        [self showView:self.districtPointsView];
        if (self.districtPointsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.districtPointsViewController.refresh();
        }
    }
}

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.infoView, self.teamsView, self.rankingsView, self.matchesView, self.alliancesView, self.awardsView, self.districtPointsView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (void)setupSegmentedControl {
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[@"Info", @"Teams", @"Rankings", @"Matches", @"Alliances", @"Stats", @"Awards"]];
    if (TBADistrictTypeNoDistrict != [self.event eventDistrict].integerValue) {
        [titles addObject:@"District Points"];
    }
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:titles];
    
    self.segmentedControl.frame = self.segmentedControlView.frame;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor TBANavigationBarColor];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlView addSubview:self.segmentedControl];
    
    [self.segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
    [self updateInterface];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.persistenceController = self.persistenceController;
        self.infoViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"TeamsViewControllerEmbed"]) {
        self.teamsViewController = segue.destinationViewController;
        self.teamsViewController.persistenceController = self.persistenceController;
        self.teamsViewController.event = self.event;
        self.teamsViewController.showSearch = NO;
    } else if ([segue.identifier isEqualToString:@"RankingsViewControllerEmbed"]) {
        self.rankingsViewController = segue.destinationViewController;
        self.rankingsViewController.persistenceController = self.persistenceController;
        self.rankingsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"MatchesViewControllerEmbed"]) {
        self.matchesViewController = segue.destinationViewController;
        self.matchesViewController.persistenceController = self.persistenceController;
        self.matchesViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"AlliancesViewControllerEmbed"]) {
        self.alliancesViewController = segue.destinationViewController;
        self.alliancesViewController.persistenceController = self.persistenceController;
        self.alliancesViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"AwardsViewControllerEmbed"]) {
        self.awardsViewController = segue.destinationViewController;
        self.awardsViewController.persistenceController = self.persistenceController;
        self.awardsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"DistrictPointsViewControllerEmbed"]) {
        self.districtPointsViewController = segue.destinationViewController;
        self.districtPointsViewController.persistenceController = self.persistenceController;
        self.districtPointsViewController.event = self.event;
        self.districtPointsViewController.showPoints = YES;
    }
}

@end
