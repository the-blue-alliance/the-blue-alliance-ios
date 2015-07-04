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
static NSString *const TeamViewControllerSegue = @"TeamViewControllerSegue";

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

        [strongSelf updateRefreshBarButtonItem:YES];
        [strongSelf refreshData];
    };
    
    self.requestsFinished = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf updateRefreshBarButtonItem:NO];
    };
    
    [self fetchTeams];
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
            [strongSelf showAlertWithTitle:@"Error fetching teams" andMessage:error.localizedDescription];
        } else {
            [strongSelf fetchTeams];
            [strongSelf.persistenceController save];
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
