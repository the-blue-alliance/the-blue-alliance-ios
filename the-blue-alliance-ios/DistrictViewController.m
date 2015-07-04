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
    TBADistrictDataTypeRankings = 1
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
            [strongSelf refreshDistrictEvents];
        } else {
            [strongSelf refreshRankings];
        }
        [strongSelf updateRefreshBarButtonItem:YES];
    };
    
    self.requestsFinished = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf updateRefreshBarButtonItem:NO];
    };
    
    [self styleInterface];
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
        
        [self fetchDistrictEvents];
    } else {
        self.eventsView.hidden = YES;
        self.rankingsView.hidden = NO;

        [self fetchDistrictRankings];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateInterface];
}

#pragma mark - District Event Methods

- (void)fetchDistrictEvents {
    if (!self.refreshing) {
        self.eventsViewController.events = nil;
        [self.eventsViewController.tableView reloadData];
    }
    
    __weak typeof(self) weakSelf = self;
    [District fetchEventsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch district events locally" andMessage:error.localizedDescription];
            return;
        }
        
        if ([events count] == 0 && !self.refreshing) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.eventsViewController.events = [Event groupEventsByWeek:events andGroupByType:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.eventsViewController.tableView reloadData];
            });
        }
        strongSelf.refreshing = NO;
    }];
}

- (void)refreshDistrictEvents {
    self.refreshing = YES;
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district events" andMessage:error.localizedDescription];
            strongSelf.refreshing = NO;
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

- (void)fetchDistrictRankings {
    if (!self.refreshing) {
        self.rankingsViewController.rankings = nil;
        [self.rankingsViewController.tableView reloadData];
    }
    
    __weak typeof(self) weakSelf = self;
    [District fetchDistrictRankingsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch district rankings locally" andMessage:error.localizedDescription];
            return;
        }
        
        if ([rankings count] == 0 && !self.refreshing) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.rankingsViewController.rankings = rankings;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.rankingsViewController.tableView reloadData];
            });
        }
        strongSelf.refreshing = NO;
    }];
}

- (void)refreshRankings {
    self.refreshing = YES;
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.yearValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district rankings" andMessage:error.localizedDescription];
            strongSelf.refreshing = NO;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:strongSelf.district inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf updateInterface];
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
        self.rankingsViewController.rankingSelected = ^(id ranking) {
            if (![ranking isKindOfClass:[DistrictRanking class]]) {
                return;
            }
            
            DistrictRanking *districtRanking = (DistrictRanking *)ranking;
            NSLog(@"Selected ranking: %@", districtRanking);
        };
    }
}


@end
