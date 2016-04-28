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
#import "TBAPointsViewController.h"
#import "EventViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "DistrictTeamViewController.h"

static NSString *const EventsViewControllerEmbed    = @"EventsViewControllerEmbed";
static NSString *const PointsViewControllerEmbed    = @"PointsViewControllerEmbed";

static NSString *const EventViewControllerSegue         = @"EventViewControllerSegue";
static NSString *const DistrictTeamViewControllerSegue  = @"DistrictTeamViewControllerSegue";

typedef NS_ENUM(NSInteger, TBADistrictDataType) {
    TBADistrictDataTypeEvents = 0,
    TBADistrictDataTypePoints
};

@interface DistrictViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, strong) IBOutlet UIView *eventsView;

@property (nonatomic, strong) TBAPointsViewController *pointsViewController;
@property (nonatomic, strong) IBOutlet UIView *pointsView;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshViewControllers = @[self.eventsViewController, self.pointsViewController];
    self.containerViews = @[self.eventsView, self.pointsView];
    
    [self styleInterface];
    [self updateInterface];
}

#pragma mark - Interface Actions

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", self.district.year, self.district.name];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
        [self showView:self.eventsView];
    } else {
        [self showView:self.pointsView];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.persistenceController = self.persistenceController;
        self.eventsViewController.district = self.district;
        self.eventsViewController.year = self.district.year;
        
        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:PointsViewControllerEmbed]) {
        self.pointsViewController = (TBAPointsViewController *)segue.destinationViewController;
        self.pointsViewController.persistenceController = self.persistenceController;
        self.pointsViewController.district = self.district;

        __weak typeof(self) weakSelf = self;
        self.pointsViewController.pointsSelected = ^(id points) {
            DistrictRanking *districtRanking = (DistrictRanking *)points;
            [weakSelf performSegueWithIdentifier:DistrictTeamViewControllerSegue sender:districtRanking];
        };
    } else if ([segue.identifier isEqualToString:EventViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.persistenceController = self.persistenceController;
        eventViewController.event = event;
    } else if ([segue.identifier isEqualToString:DistrictTeamViewControllerSegue]) {
        DistrictRanking *districtRanking = (DistrictRanking *)sender;
        
        DistrictTeamViewController *districtTeamViewController = segue.destinationViewController;
        districtTeamViewController.persistenceController = self.persistenceController;
        districtTeamViewController.district = self.district;
        districtTeamViewController.districtRanking = districtRanking;
    }
}


@end
