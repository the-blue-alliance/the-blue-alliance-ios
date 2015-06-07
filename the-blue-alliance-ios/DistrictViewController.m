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
#import "DistrictEventsViewController.h"
#import "DistrictRankingsViewController.h"
#import "TBAKit.h"


#import "Team.h"
#import "Team+Fetch.h"


typedef NS_ENUM(NSInteger, TBADistrictDataType) {
    TBADistrictDataTypeEvents = 0,
    TBADistrictDataTypeRankings = 1
};

@interface DistrictViewController ()

@property (nonatomic, strong) IBOutlet UIView *eventsView;
@property (nonatomic, strong) IBOutlet UIView *rankingsView;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) DistrictEventsViewController *eventsViewController;
@property (nonatomic, strong) DistrictRankingsViewController *rankingsViewController;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
                [strongSelf refreshEvents];
            } else {
                [strongSelf refreshRankings];
            }
            [strongSelf updateRefreshBarButtonItem:YES];
        }
    };
    self.eventsViewController.refresh = self.refresh;
    self.rankingsViewController.refresh = self.refresh;
    
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}


#pragma mark - Interface Actions

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ Districts", @(self.district.year), self.district.name];

    [self updateInterface];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictDataTypeEvents) {
        self.eventsView.hidden = NO;
        self.rankingsView.hidden = YES;
        
        [self.eventsViewController fetchDistricts];
        [self.eventsViewController.tableView reloadData];
    } else {
        self.eventsView.hidden = YES;
        self.rankingsView.hidden = NO;

        [self.rankingsViewController fetchDistrictRankings];
        [self.rankingsViewController.tableView reloadData];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];

    [self updateInterface];
}


#pragma mark - Data Methods

- (void)refreshEvents {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchEventsForDistrictShort:self.district.key forYear:self.district.year withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district events" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.eventsViewController fetchDistricts];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

- (void)refreshRankings {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.year withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching district rankings" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:strongSelf.district inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.rankingsViewController fetchDistrictRankings];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
/*
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"district/%@/%@/rankings", [District abbrevForDistrictType:self.districtType], @(self.year)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading district rankings" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertView show];
                [self updateRefreshBarButtonItem:NO];
            });
            return;
        }
        if (!error && [objects isKindOfClass:[NSArray class]]) {
            for (NSDictionary *districtRanking in objects) {
                NSLog(@"DR: %@", districtRanking);

                DistrictRanking *dr = [TBAImporter importDistrictRanking:districtRanking];
                dr.year = @(self.year);
                
                NSArray *teams = [Team fetchTeamsForKeys:@[dr.team_key] fromContext:[TBAApp managedObjectContext]];
                if (!teams || [teams count] == 0) {
                    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"team/%@", dr.team_key] callback:^(id objects, NSError *error) {
                        self.currentRequestIdentifier = 0;
                        
                        if (error) {
                            NSLog(@"Error fetching team %@: %@", dr.team_key, error.localizedDescription);
                        }
                        if (!error && [objects isKindOfClass:[NSDictionary class]]) {
                            Team *team = [TBAImporter importTeam:objects];
                            [self setDistrictPoints:districtRanking[@"event_points"] forDistrictRanking:dr forTeam:team];
                        }
                    }];
                } else {
                    Team *team = [teams firstObject];
                    [self setDistrictPoints:districtRanking[@"event_points"] forDistrictRanking:dr forTeam:team];
                }
            }
        }
    }];
*/
}

/*
- (void)setDistrictPoints:(NSDictionary *)districtPoints forDistrictRanking:(DistrictRanking *)districtRanking forTeam:(Team *)team {
    for (NSString *eventKey in districtPoints) {
        NSDictionary *districtPointsDict = [districtPoints objectForKey:eventKey];
        DistrictPoints *dp = [TBAImporter importDistrictPoints:districtPointsDict];
        dp.district_ranking = districtRanking;
        dp.team = team;
        
        // Make sure Event exists
        Event *event = [Event fetchEventWithKey:eventKey fromContext:[TBAApp managedObjectContext]];
        if (!event) {
            self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"event/%@", eventKey] callback:^(id objects, NSError *error) {
                self.currentRequestIdentifier = 0;
                
                if (error) {
                    NSLog(@"Error fetching event %@: %@", eventKey, error.localizedDescription);
                }
                if (!error && [objects isKindOfClass:[NSDictionary class]]) {
                    Event *event = [TBAImporter importEvent:objects];
                    [self setEvent:event forDistrictPoints:dp updateInterface:YES];
                }
            }];
        } else {
            [self setEvent:event forDistrictPoints:dp updateInterface:YES];
        }
    }
}

- (void)setEvent:(Event *)event forDistrictPoints:(DistrictPoints *)districtPoints updateInterface:(BOOL)update {
    districtPoints.event = event;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TBAApp saveContext];

        if (update) {
            [self updateRefreshBarButtonItem:NO];
            
            [self.rankingsTableViewController fetchDistrictRankings];
            [self updateInterface];
        }
    });
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventsViewControllerEmbed"]) {
        self.eventsViewController = (DistrictEventsViewController *)segue.destinationViewController;

        self.eventsViewController.persistenceController = self.persistenceController;
        self.eventsViewController.district = self.district;
    } else if ([segue.identifier isEqualToString:@"RankingsViewControllerEmbed"]) {
        self.rankingsViewController = (DistrictRankingsViewController *)segue.destinationViewController;

        self.rankingsViewController.persistenceController = self.persistenceController;
        self.rankingsViewController.district = self.district;
    }
}


@end
