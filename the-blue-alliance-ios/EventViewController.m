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
    TBAEventDataTypeDistrictPoints,
    TBAEventDataTypeStats,
    TBAEventDataTypeAwards
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

@property (nonatomic, strong) NSArray<NSNumber *> *eventWeeks;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeInfo) {
            [strongSelf refreshEvent];
        } else if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeTeams) {
            [strongSelf.teamsViewController hideNoDataView];
            [strongSelf refreshTeams];
        } else if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeRankings) {
            [strongSelf.rankingsViewController hideNoDataView];
            [strongSelf refreshRankings];
        } else if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeMatches) {
            [strongSelf.matchesViewController hideNoDataView];
            [strongSelf refreshMatches];
        } else if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeAlliances) {
            [strongSelf.matchesViewController hideNoDataView];
            [strongSelf refreshEvent];
        }
        [strongSelf updateRefreshBarButtonItem:YES];
    };
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.infoView, self.teamsView, self.rankingsView, self.matchesView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [self.event friendlyNameWithYear:YES];
    [self setupSegmentedControl];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeInfo) {
        [self showView:self.infoView];
        [self fetchEventAndRefresh:NO];
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeTeams) {
        [self showView:self.teamsView];
        if (self.teamsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeRankings) {
        [self showView:self.rankingsView];
        if (self.rankingsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeMatches) {
        [self showView:self.matchesView];
        if (self.matchesViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.refresh();
        }
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeAlliances) {
        [self showView:self.alliancesView];
        if (self.alliancesViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.refresh();
        }
    }
}

- (void)setupSegmentedControl {
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[@"Info", @"Teams", @"Rankings", @"Matches", @"Alliances", @"Stats", @"Awards"]];
    if (TBADistrictTypeNoDistrict != [self.event eventDistrict].integerValue) {
        [titles insertObject:@"District Points" atIndex:[titles indexOfObject:@"Stats"]];
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
    [self cancelRefresh];
    [self updateInterface];
}

#pragma mark - Event Info

- (void)fetchEventAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [Event fetchEventForKey:self.event.key fromContext:self.persistenceController.managedObjectContext checkUpstream:NO withCompletionBlock:^(Event *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to fetch event info locally"];
            });
            return;
        }
        
        if (!event) {
            if (refresh) {
                [self refresh];
            }
        } else {
            strongSelf.event = event;
            strongSelf.infoViewController.event = event;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventWithModelEvent:event inManagedObjectContext:self.persistenceController.managedObjectContext];
                [strongSelf fetchEventAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Teams

- (void)refreshTeams {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchTeamsForEventKey:self.event.key withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload teams for event"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *localTeams = [Team insertTeamsWithModelTeams:teams inManagedObjectContext:self.persistenceController.managedObjectContext];
                [self.event setTeams:[[NSSet alloc] initWithArray:localTeams]];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Rankings

- (void)refreshRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForEventKey:self.event.key withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload event rankings"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [EventRanking insertEventRankingsWithEventRankings:rankings forEvent:self.event inManagedObjectContext:self.persistenceController.managedObjectContext];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Matches

- (void)refreshMatches {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMatchesForEventKey:self.event.key withCompletionBlock:^(NSArray *matches, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload event matches"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Match insertMatchesWithModelMatches:matches forEvent:self.event inManagedObjectContext:self.persistenceController.managedObjectContext];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Alliances

// Do I even have to do anything here like what?

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
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
    }
}

@end
