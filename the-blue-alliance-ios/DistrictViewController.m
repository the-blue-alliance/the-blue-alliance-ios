//
//  DistrictViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictViewController.h"
#import "District.h"
#import "DistrictRanking.h"
#import "EventPoints.h"
#import "Event+Fetch.h"
#import "TBAEventsViewController.h"
#import "EventViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "TBARankingsViewController.h"

static NSString *const EventsViewControllerEmbed    = @"EventsViewControllerEmbed";
static NSString *const RankingsViewControllerEmbed  = @"RankingsViewControllerEmbed";

static NSString *const EventViewControllerSegue     = @"EventViewControllerSegue";

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

    [self styleInterface];
}

#pragma mark - Private Methods

- (void)cancelRefreshes {
    [self.eventsViewController cancelRefresh];
    [self.rankingsViewController cancelRefresh];
}

#pragma mark - Interface Actions

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", self.district.year, self.district.name];

    [self updateInterface];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
        [self showView:self.eventsView];
        if (self.eventsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.eventsViewController.refresh();
        }
    } else {
        [self showView:self.rankingsView];
        if (self.rankingsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.rankingsViewController.refresh();
        }
    }
}

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.eventsView, self.rankingsView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
    [self updateInterface];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.district = self.district;
        self.eventsViewController.persistenceController = self.persistenceController;
        self.eventsViewController.year = self.district.year;
        
        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:RankingsViewControllerEmbed]) {
        self.rankingsViewController = (TBARankingsViewController *)segue.destinationViewController;
        self.rankingsViewController.district = self.district;
        self.rankingsViewController.persistenceController = self.persistenceController;

        self.rankingsViewController.rankingSelected = ^(id ranking) {
            DistrictRanking *districtRanking = (DistrictRanking *)ranking;
            NSLog(@"Selected ranking: %@", districtRanking);
        };
    } else if ([segue.identifier isEqualToString:EventViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.event = event;
        eventViewController.persistenceController = self.persistenceController;
    }
}


@end
