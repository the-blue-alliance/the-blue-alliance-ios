//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 4/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAInfoViewController.h"
#import "TBATeamsViewController.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "Team.h"
#import "Team+Fetch.h"

typedef NS_ENUM(NSInteger, TBAEventDataType) {
    TBAEventDataTypeInfo = 0,
    TBAEventDataTypeTeams,
    TBAEventDataTypeRankings,
    TBAEventDataTypeMatches,
    TBAEventDataTypeAlliances,
    TBAEventDataTypeDistrictPoints,
    TBAEventDataTypeStats,
    TBAEventDataTypeAwards
};

@interface EventViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;
@property (nonatomic, weak) IBOutlet UIView *teamsView;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeInfo) {
            [strongSelf refreshEvent];
        } else if (strongSelf.segmentedControl.selectedSegmentIndex == TBAEventDataTypeTeams) {
            [strongSelf.teamsViewController hideNoDataView];
            [strongSelf refreshTeams];
        }
        [strongSelf updateRefreshBarButtonItem:YES];
    };
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [self.event friendlyNameWithYear:YES];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeInfo) {
        self.infoView.hidden = NO;
        self.teamsView.hidden = YES;
        
        [self fetchEventAndRefresh:NO];
    } else if (self.segmentedControl.selectedSegmentIndex == TBAEventDataTypeTeams) {
        self.teamsView.hidden = NO;
        self.infoView.hidden = YES;
        
        [self fetchTeamsAndRefresh:NO];
    }
    // and the rest of our segmented control in here
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateInterface];
}

#pragma mark - Event Info

- (void)fetchEventAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [Event fetchEventForKey:self.event.key fromContext:self.persistenceController.managedObjectContext checkUpstream:NO withCompletionBlock:^(Event *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to fetch event info locally"];
            });
            return;
        }
        
        if (!event) {
            if (refresh) {
                [self refresh];
            }
        } else {
            strongSelf.event = event;
            strongSelf.infoViewController.event = event;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.infoViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventWithModelEvent:event inManagedObjectContext:self.persistenceController.managedObjectContext];
                [strongSelf fetchEventAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Teams

- (void)fetchTeamsAndRefresh:(BOOL)refresh {
    if (!self.event.teams) {
        if (refresh) {
            [self refresh];
        }
    } else {
        NSArray *teams = [self.event.teams allObjects];
        if (teams) {
            teams = [teams sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"teamNumber" ascending:YES]]];
        }
        self.teamsViewController.teams = teams;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.teamsViewController.tableView reloadData];
        });
    }
}

- (void)refreshTeams {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchTeamsForEventKey:self.event.key withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload teams for event"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *localTeams = [Team insertTeamsWithModelTeams:teams inManagedObjectContext:self.persistenceController.managedObjectContext];
                [self.event setTeams:[[NSSet alloc] initWithArray:localTeams]];

                [strongSelf fetchTeamsAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"TeamsViewControllerEmbed"]) {
        self.teamsViewController = segue.destinationViewController;
    }
}

@end
