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
#import "TBAKit.h"
#import "TBAEventsViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "TBARankingsViewController.h"

typedef NS_ENUM(NSInteger, TBADistrictDataType) {
    TBADistrictDataTypeEvents = 0,
    TBADistrictDataTypeRankings
};

@interface DistrictViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, strong) IBOutlet UIView *eventsView;

@property (nonatomic, strong) TBARankingsViewController *rankingsViewController;
@property (nonatomic, strong) IBOutlet UIView *rankingsView;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
            [strongSelf.eventsViewController hideNoDataView];
            [strongSelf refreshDistrictEvents];
        } else {
            [strongSelf.rankingsViewController hideNoDataView];
            [strongSelf refreshRankings];
        }
        [strongSelf updateRefreshBarButtonItem:YES];
    };
    
    [self fetchDistrictEventsAndRefresh:YES];
    [self styleInterface];
}

#pragma mark - Interface Actions

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.eventsView, self.rankingsView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", self.district.year, self.district.name];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
        [self showView:self.eventsView];
        [self fetchDistrictEventsAndRefresh:NO];
    } else {
        [self showView:self.rankingsView];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateInterface];
}

#pragma mark - District Event Methods

- (void)removeDistrictEvents {
    self.eventsViewController.events = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eventsViewController.tableView reloadData];
    });
}

- (void)fetchDistrictEventsAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [District fetchEventsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString *errorMessage = @"Unable to fetch district events locally";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.eventsViewController.events) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.eventsViewController showNoDataViewWithText:errorMessage];
                }
            });
            return;
        }
        
        if ([events count] == 0) {
            if (refresh && strongSelf.refresh) {
                strongSelf.refresh();
            } else {
                [strongSelf removeDistrictEvents];
            }
        } else {
            strongSelf.eventsViewController.events = [Event groupEventsByWeek:events andGroupByType:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.eventsViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshDistrictEvents {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            NSString *errorMessage = @"Unable to load district events";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.eventsViewController.events) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.eventsViewController showNoDataViewWithText:errorMessage];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Disitrict Ranking Methods

- (void)refreshRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload district rankings"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // TODO: These large inserts are hanging our UI thread. We need to look in to fixing it.
                [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:strongSelf.district inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventsViewControllerEmbed"]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.eventSelected = ^(Event *event) {
            NSLog(@"Selected event: %@", event.shortName);
        };
    } else if ([segue.identifier isEqualToString:@"RankingsViewControllerEmbed"]) {
        self.rankingsViewController = (TBARankingsViewController *)segue.destinationViewController;
        self.rankingsViewController.district = self.district;
        self.rankingsViewController.persistenceController = self.persistenceController;
        self.rankingsViewController.rankingSelected = ^(id ranking) {
            DistrictRanking *districtRanking = (DistrictRanking *)ranking;
            NSLog(@"Selected ranking: %@", districtRanking);
        };
    }
}


@end
