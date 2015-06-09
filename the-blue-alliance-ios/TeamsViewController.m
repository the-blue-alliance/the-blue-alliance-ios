//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "OrderedDictionary.h"
#import "TBAImporter.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TBATeamTableViewCell.h"

#import "TBATeamsViewController.h"

static NSString *const TeamsViewControllerSegue = @"TeamsViewControllerEmbed";

@interface TeamsViewController ()

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;
@property (nonatomic, weak) IBOutlet UIView *teamsView;

@end


@implementation TeamsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            [strongSelf refreshData];
        }
    };
    
    [self fetchTeams];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}

#pragma mark - Data Methods

- (void)fetchTeams {
    __weak typeof(self) weakSelf = self;
    [Team fetchAllTeamsFromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch teams locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!teams || [teams count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.teamsViewController.teams = teams;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.teamsViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [Team fetchAllTeamsWithTaskIdChange:^(NSUInteger newTaskId, NSArray *batchTeam) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentRequestIdentifier = newTaskId;

        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [tmpContext setParentContext:strongSelf.persistenceController.managedObjectContext];
        [tmpContext performBlock:^{
            [Team insertTeamsWithModelTeams:batchTeam inManagedObjectContext:tmpContext];
            [tmpContext save:nil];
        }];
    } withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching teams" andMessage:error.localizedDescription];
        } else {
            [strongSelf fetchTeams];
            [strongSelf.persistenceController save];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TeamsViewControllerSegue]) {
        self.teamsViewController = (TBATeamsViewController *)segue.destinationViewController;
        self.teamsViewController.showSearch = YES;
        self.teamsViewController.teamSelected = ^(Team *team) {
            NSLog(@"Team selected: %lld", team.teamNumber);
        };
    }
}

@end
