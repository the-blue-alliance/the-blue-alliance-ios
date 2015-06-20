//
//  DistrictViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictViewController.h"

#import "District.h"
#import "District+Fetch.h"
#import "DistrictRanking.h"
#import "EventPoints.h"

#import "Event+Fetch.h"
#import "DistrictRankingsViewController.h"
#import "TBAKit.h"

#import "TBAEventsViewController.h"

#import "Team.h"
#import "Team+Fetch.h"


typedef NS_ENUM(NSInteger, TBADistrictDataType) {
    TBADistrictDataTypeEvents = 0,
    TBADistrictDataTypeRankings = 1
};

@interface DistrictViewController ()

@property (nonatomic, strong) IBOutlet UIView *eventsView;
@property (nonatomic, strong) IBOutlet UIView *rankingsView;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, strong) DistrictRankingsViewController *rankingsViewController;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
                [strongSelf refreshEvents];
            } else {
                [strongSelf refreshRankings];
            }
            [strongSelf updateRefreshBarButtonItem:YES];
        }
    };
    
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}


#pragma mark - Interface Actions

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", self.district.year, self.district.name];

    [self updateInterface];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
        self.eventsView.hidden = NO;
        self.rankingsView.hidden = YES;
        
        [self fetchDistricts];
        [self.eventsViewController.tableView reloadData];
    } else {
        self.eventsView.hidden = YES;
        self.rankingsView.hidden = NO;

        [self.rankingsViewController fetchDistrictRankings];
        [self.rankingsViewController.tableView reloadData];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];

    [self updateInterface];
}


#pragma mark - Data Methods

- (void)fetchDistricts {
    __weak typeof(self) weakSelf = self;
    [District fetchEventsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch district events locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!events || [events count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.eventsViewController.events = [Event groupEventsByWeek:events andGroupByType:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.eventsViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshEvents {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchEventsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district events" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchDistricts];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

- (void)refreshRankings {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district rankings" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:strongSelf.district inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.rankingsViewController fetchDistrictRankings];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventsViewControllerEmbed"]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.eventSelected = ^(Event *event) {
            NSLog(@"Selected event: %@", event.shortName);
        };
    } else if ([segue.identifier isEqualToString:@"RankingsViewControllerEmbed"]) {
        self.rankingsViewController = (DistrictRankingsViewController *)segue.destinationViewController;

        self.rankingsViewController.persistenceController = self.persistenceController;
        self.rankingsViewController.district = self.district;
    }
}


@end
