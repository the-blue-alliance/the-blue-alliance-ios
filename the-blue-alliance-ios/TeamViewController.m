//
//  TeamViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/7/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamViewController.h"
#import "TBAEventsViewController.h"
#import "TBATeamInfoViewController.h"
#import "TBAMediaCollectionViewController.h"
#import "EventTeamViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"
#import "Media.h"

static NSString *const InfoViewControllerEmbed      = @"InfoViewControllerEmbed";
static NSString *const EventsViewControllerEmbed    = @"EventsViewControllerEmbed";
static NSString *const MediaViewControllerEmbed     = @"MediaViewControllerEmbed";

static NSString *const EventTeamViewControllerSegue = @"EventTeamViewControllerSegue";

@interface TeamViewController ()

@property (nonatomic, strong) TBATeamInfoViewController *infoViewController;
@property (nonatomic, strong) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, strong) IBOutlet UIView *eventsView;

@property (nonatomic, strong) TBAMediaCollectionViewController *mediaCollectionViewController;
@property (nonatomic, strong) IBOutlet UIView *mediaView;

@end

@implementation TeamViewController

#pragma mark - Properities

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshViewControllers = @[self.infoViewController, self.eventsViewController, self.mediaCollectionViewController];
    self.containerViews = @[self.infoView, self.eventsView, self.mediaView];
    
    __weak typeof(self) weakSelf = self;
    self.yearSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf cancelRefreshes];

        strongSelf.currentYear = year;
        strongSelf.mediaCollectionViewController.year = year;
        strongSelf.eventsViewController.year = year;
    };
    
    [self fetchYearsParticipated];
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
}

#pragma mark - Data Methods

- (void)fetchYearsParticipated {
    NSArray *years = [self.team sortedYearsParticipated];
    if (!years || [years count] == 0) {
        self.currentYear = 0;
        [self refreshYearsParticipated];
    } else {
        self.years = years;
        if (self.currentYear == 0) {
            NSNumber *year = [years firstObject];
            
            self.currentYear = year;
            self.mediaCollectionViewController.year = year;
            self.eventsViewController.year = year;
        }
    }
}

- (void)refreshYearsParticipated {
    __weak typeof(self) weakSelf = self;
    [[TBAKit sharedKit] fetchYearsParticipatedForTeamKey:self.team.key withCompletionBlock:^(NSArray *years, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!error) {
            Team *team = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.team.objectID];

            [strongSelf.persistenceController performChanges:^{
                team.yearsParticipated = years;
            } withCompletion:^{
                [strongSelf fetchYearsParticipated];
            }];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:InfoViewControllerEmbed]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.team = self.team;
    } else if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = segue.destinationViewController;
        self.eventsViewController.team = self.team;
        self.eventsViewController.year = self.currentYear;
        
        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:MediaViewControllerEmbed]) {
        self.mediaCollectionViewController = segue.destinationViewController;
        self.mediaCollectionViewController.team = self.team;
        self.mediaCollectionViewController.year = self.currentYear;
    } else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.event = event;
        eventTeamViewController.team = self.team;
    }
}

@end
