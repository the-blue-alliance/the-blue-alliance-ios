//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "OrderedDictionary.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TBATeamTableViewCell.h"
#import "TBATeamsViewController.h"
#import "TeamViewController.h"

static NSString *const TeamsViewControllerEmbed = @"TeamsViewControllerEmbed";
static NSString *const TeamViewControllerSegue  = @"TeamViewControllerSegue";

@interface TeamsViewController ()

@property (nonatomic, strong) TBATeamsViewController *teamsViewController;

@end


@implementation TeamsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.teamsViewController hideNoDataView];
        [strongSelf updateRefreshBarButtonItem:YES];
        [strongSelf refreshData];
    };
    
    [self fetchTeamsAndRefresh:YES];
}

#pragma mark - Data Methods

- (void)removeData {
    self.teamsViewController.teams = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.teamsViewController.tableView reloadData];
    });
}

- (void)fetchTeamsAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [Team fetchAllTeamsFromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString *errorMessage = @"Unable to fetch teams locally";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.teamsViewController.teams) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.teamsViewController showNoDataViewWithText:errorMessage];
                }
            });
            return;
        }
        
        if ([teams count] == 0) {
            if (refresh && strongSelf.refresh) {
                strongSelf.refresh();
            } else {
                [strongSelf removeData];
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
    __block NSUInteger currentRequest;
    
    __weak typeof(self) weakSelf = self;
    currentRequest = [Team fetchAllTeamsWithTaskIdChange:^(NSUInteger newTaskId, NSArray *batchTeam) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf addRequestIdentifier:newTaskId];
        [strongSelf removeRequestIdentifier:currentRequest];
        currentRequest = newTaskId;
        
        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [tmpContext setParentContext:strongSelf.persistenceController.managedObjectContext];
        [tmpContext performBlock:^{
            [Team insertTeamsWithModelTeams:batchTeam inManagedObjectContext:tmpContext];
            [tmpContext save:nil];
        }];
    } withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:currentRequest];
        
        if (error) {
            NSString *errorMessage = @"Unable to load teams";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.teamsViewController.teams) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.teamsViewController showNoDataViewWithText:errorMessage];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf fetchTeamsAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:currentRequest];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TeamsViewControllerEmbed]) {
        self.teamsViewController = (TBATeamsViewController *)segue.destinationViewController;
        self.teamsViewController.showSearch = YES;
        
        __weak typeof(self) weakSelf = self;
        self.teamsViewController.teamSelected = ^(Team *team) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf performSegueWithIdentifier:TeamViewControllerSegue sender:team];
        };
    } else if ([segue.identifier isEqualToString:TeamViewControllerSegue]) {
        Team *team = (Team *)sender;
    
        TeamViewController *teamViewController = segue.destinationViewController;
        teamViewController.team = team;
        teamViewController.persistenceController = self.persistenceController;
    }
}

@end
