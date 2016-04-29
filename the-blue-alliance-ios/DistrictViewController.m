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

@interface DistrictViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, strong) TBAPointsViewController *pointsViewController;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshViewControllers = @[self.eventsViewController, self.pointsViewController];
    
    [self styleInterface];
}

#pragma mark - Interface Actions

- (void)styleInterface {
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", self.district.year, self.district.name];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.district = self.district;
        self.eventsViewController.year = self.district.year;
        
        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:PointsViewControllerEmbed]) {
        self.pointsViewController = (TBAPointsViewController *)segue.destinationViewController;
        self.pointsViewController.district = self.district;

        __weak typeof(self) weakSelf = self;
        self.pointsViewController.pointsSelected = ^(id points) {
            DistrictRanking *districtRanking = (DistrictRanking *)points;
            [weakSelf performSegueWithIdentifier:DistrictTeamViewControllerSegue sender:districtRanking];
        };
    } else if ([segue.identifier isEqualToString:EventViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.event = event;
    } else if ([segue.identifier isEqualToString:DistrictTeamViewControllerSegue]) {
        DistrictRanking *districtRanking = (DistrictRanking *)sender;
        
        DistrictTeamViewController *districtTeamViewController = segue.destinationViewController;
        districtTeamViewController.district = self.district;
        districtTeamViewController.districtRanking = districtRanking;
    }
}


@end
