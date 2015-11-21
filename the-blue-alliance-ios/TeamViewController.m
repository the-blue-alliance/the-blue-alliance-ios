//
//  TeamViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/7/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamViewController.h"
#import "TBAEventsViewController.h"
#import "TBAInfoViewController.h"
#import "TBAMediaCollectionViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"
#import "Media.h"

static NSString *const EventsViewControllerEmbed    = @"EventsViewControllerEmbed";
static NSString *const InfoViewControllerEmbed      = @"InfoViewControllerEmbed";
static NSString *const MediaViewControllerEmbed     = @"MediaViewControllerEmbed";

typedef NS_ENUM(NSInteger, TBATeamDataType) {
    TBATeamDataTypeInfo = 0,
    TBATeamDataTypeEvents,
    TBATeamDataTypeMedia
};

@interface TeamViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;

@property (nonatomic, strong) TBAMediaCollectionViewController *mediaCollectionViewController;
@property (nonatomic, weak) IBOutlet UIView *mediaView;

@end

@implementation TeamViewController

#pragma mark - Properities

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    // TODO: Need some way to refresh years participated
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentYear = selectedYear;

        strongSelf.mediaCollectionViewController.year = selectedYear;
        if (strongSelf.mediaCollectionViewController.fetchedResultsController.fetchedObjects.count == 0) {
            strongSelf.mediaCollectionViewController.refresh();
        }

        strongSelf.eventsViewController.year = @(selectedYear);
        if (strongSelf.eventsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            strongSelf.eventsViewController.refresh();
        }
    };
    
    [self fetchYearsParticipatedAndRefresh:YES];
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.infoView, self.eventsView, self.mediaView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
}

- (void)updateInterface {
    // TODO: Find a better pattern for canceling refreshes
    if (self.segmentedControl.selectedSegmentIndex == TBATeamDataTypeInfo) {
        [self showView:self.infoView];
        
        [self.eventsViewController cancelRefresh];
        [self.mediaCollectionViewController cancelRefresh];
    } else if (self.segmentedControl.selectedSegmentIndex == TBATeamDataTypeEvents) {
        [self showView:self.eventsView];
        
        [self.infoViewController cancelRefresh];
        [self.mediaCollectionViewController cancelRefresh];
        
        if (self.eventsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.eventsViewController.refresh();
        }
    } else {
        [self showView:self.mediaView];
        
        [self.infoViewController cancelRefresh];
        [self.eventsViewController cancelRefresh];
        
        if (self.mediaCollectionViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.mediaCollectionViewController.refresh();
        }
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self updateInterface];
}

#pragma mark - Years Participated

- (void)fetchYearsParticipatedAndRefresh:(BOOL)refresh {
    NSArray *years = [self.team sortedYearsParticipated];
    if (!years || [years count] == 0) {
        self.currentYear = 0;
        if (refresh) {
            [self refreshYearsParticipated];
        }
    } else {
        self.years = years;
        if (self.currentYear == 0) {
            NSUInteger year = [(NSNumber *)[years firstObject] unsignedIntegerValue];
            
            self.currentYear = year;
            self.mediaCollectionViewController.year = year;
        }
    }
}

- (void)refreshYearsParticipated {
    __weak typeof(self) weakSelf = self;
    [[TBAKit sharedKit] fetchYearsParticipatedForTeamKey:self.team.key withCompletionBlock:^(NSArray *years, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.team.yearsParticipated = years;
                [strongSelf fetchYearsParticipatedAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:InfoViewControllerEmbed]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.persistenceController = self.persistenceController;
        self.infoViewController.team = self.team;
    } else if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = segue.destinationViewController;
        self.eventsViewController.persistenceController = self.persistenceController;
        self.eventsViewController.team = self.team;
        self.eventsViewController.year = @(self.currentYear);
        
        self.eventsViewController.eventSelected = ^(Event *event) {
            NSLog(@"Selected event: %@", event.shortName);
        };
    } else if ([segue.identifier isEqualToString:MediaViewControllerEmbed]) {
        self.mediaCollectionViewController = segue.destinationViewController;
        self.mediaCollectionViewController.persistenceController = self.persistenceController;
        self.mediaCollectionViewController.team = self.team;
        self.mediaCollectionViewController.year = self.currentYear;
    }
}

@end
