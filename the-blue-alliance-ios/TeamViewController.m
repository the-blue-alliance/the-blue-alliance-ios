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
#import "Team.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"
#import "Media.h"
#import "Media+Fetch.h"

typedef NS_ENUM(NSInteger, TBATeamDataType) {
    TBATeamDataTypeInfo = 0,
    TBATeamDataTypeEvents
};

@interface TeamViewController ()

@property (nonatomic, assign) BOOL attemptedToFetchMedia;

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;

@end

@implementation TeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.segmentedControl.selectedSegmentIndex == TBATeamDataTypeInfo) {
                [strongSelf refreshTeamInfo];
            } else {
                [strongSelf refreshEvents];
            }
            [strongSelf updateRefreshBarButtonItem:YES];
        }
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentYear = selectedYear;
        
        [strongSelf cancelRefresh];
        [strongSelf updateRefreshBarButtonItem:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf.segmentedControl.selectedSegmentIndex == TBATeamDataTypeInfo) {
                [strongSelf refreshTeamInfo];
            } else {
                [strongSelf refreshEvents];
            }
        });
    };
    
    [self configureYears];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
    
    [self updateInterface];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBATeamDataTypeInfo) {
        self.infoView.hidden = NO;
        self.eventsView.hidden = YES;
        
        [self fetchTeam];
        [self fetchYearsParticipated];
        if (self.currentYear != 0) {
            [self fetchMedia];
        }
    } else {
        self.eventsView.hidden = NO;
        self.infoView.hidden = YES;
        
        [self fetchEvents];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
    
    [self updateInterface];
}

#pragma mark - Data Methods

- (void)configureYears {
    NSArray *years = self.team.yearsParticipated;
    if (!years || [years count] == 0) {
        self.currentYear = 0;
    } else {
        self.years = years;
    }
}

#pragma mark - Team Info Refresh (Upstream) Data Methods

- (void)refreshTeamInfo {
    [self refreshYearsParticipated];
    [self refreshTeam];

    self.attemptedToFetchMedia = NO;
    [self refreshMedia];
}

- (void)refreshYearsParticipated {
    [self updateRefreshBarButtonItem:YES];
    
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchYearsParticipatedForTeamKey:self.team.key withCompletionBlock:^(NSArray *years, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching years participated" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.team.yearsParticipated = years;
                [strongSelf fetchYearsParticipated];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

- (void)refreshTeam {
    [self updateRefreshBarButtonItem:YES];
    
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchTeamForTeamKey:self.team.key withCompletionBlock:^(TBATeam *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching team info" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Team insertTeamWithModelTeam:team inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchTeam];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

- (void)refreshMedia {
    if (self.currentYear == 0) {
        return;
    }
    
    [self updateRefreshBarButtonItem:YES];

    __block NSInteger year = self.currentYear;
    
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchMediaForTeamKey:self.team.key andYear:self.currentYear withCompletionBlock:^(NSArray *media, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.attemptedToFetchMedia = YES;
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching media" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Media insertMediasWithModelMedias:media forTeam:self.team andYear:year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchMedia];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

#pragma mark - Team Info Fetch (Local) Data Methods

- (void)fetchYearsParticipated {
    NSArray *years = [self.team sortedYearsParticipated];
    if (!years || [years count] == 0) {
        [self refreshYearsParticipated];
    } else {
        self.years = years;
        if (self.currentYear == 0) {
            self.currentYear = [(NSNumber *)[years firstObject] integerValue];
            [self fetchMedia];
        }
    }
}

- (void)fetchTeam {
    __weak typeof(self) weakSelf = self;
    [Team fetchTeamForKey:self.team.key fromContext:self.persistenceController.managedObjectContext checkUpstream:NO withCompletionBlock:^(Team *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch team locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!team) {
            [self refreshTeam];
        } else {
            strongSelf.team = team;
            strongSelf.infoViewController.team = team;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoViewController.tableView reloadData];
            });
        }
    }];
}

- (void)fetchMedia {
    __weak typeof(self) weakSelf = self;
    [Media fetchMediaForYear:self.currentYear forTeam:self.team fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *media, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch media locally" andMessage:error.localizedDescription];
            return;
        }
        
        if ((!media || [media count] == 0) && !self.attemptedToFetchMedia) {
            [strongSelf refreshMedia];
        } else {
            strongSelf.infoViewController.media = media;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoViewController.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Events Data Methods

- (void)fetchEvents {
    NSArray *events = [self.team sortedEventsForYear:self.currentYear];
    
    if (!events || [events count] == 0) {
        [self refreshEvents];
    } else {
        self.eventsViewController.events = [Event groupEventsByWeek:events andGroupByType:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eventsViewController.tableView reloadData];
        });
    }
}

- (void)refreshEvents {
    [self updateRefreshBarButtonItem:YES];
    // TODO: Set events table view to no data and show a loading state?
    
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchEventsForTeamKey:self.team.key andYear:self.currentYear withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching events for team" andMessage:error.localizedDescription];
        } else {
            NSArray *newEvents = [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
            [strongSelf.team addEvents:[NSSet setWithArray:newEvents]];
            [strongSelf updateInterface];
            [strongSelf.persistenceController save];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.team = self.team;
    } else if ([segue.identifier isEqualToString:@"EventsViewControllerEmbed"]) {
        self.eventsViewController = segue.destinationViewController;
        self.eventsViewController.eventSelected = ^(Event *event) {
            NSLog(@"Selected event: %@", event.shortName);
        };
    }
}

@end
