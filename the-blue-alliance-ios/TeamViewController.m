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
    self.yearSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelRefreshes];

        strongSelf.currentYear = year;
        strongSelf.mediaCollectionViewController.year = year;
        strongSelf.eventsViewController.year = year;
        
        [strongSelf updateInterface];
    };
    
    [self registerForChangeNotifications];
    [self fetchYearsParticipatedAndRefresh:YES];
    [self styleInterface];
}

#pragma mark - Private Methods

- (void)registerForChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            if (obj == self.team) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fetchYearsParticipatedAndRefresh:NO];
                });
            }
        }
    }];
}

- (void)cancelRefreshes {
    [self.infoViewController cancelRefresh];
    [self.eventsViewController cancelRefresh];
    [self.mediaCollectionViewController cancelRefresh];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBATeamDataTypeInfo) {
        [self showView:self.infoView];
    } else if (self.segmentedControl.selectedSegmentIndex == TBATeamDataTypeEvents) {
        [self showView:self.eventsView];
        if (self.eventsViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.eventsViewController.refresh();
        }
    } else {
        [self showView:self.mediaView];
        if (self.mediaCollectionViewController.fetchedResultsController.fetchedObjects.count == 0) {
            self.mediaCollectionViewController.refresh();
        }
    }
}

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.infoView, self.eventsView, self.mediaView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
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
            [strongSelf.persistenceController performChanges:^{
                strongSelf.team.yearsParticipated = years;
            }];
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
        self.eventsViewController.year = self.currentYear;
        
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
