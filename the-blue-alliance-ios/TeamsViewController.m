//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "Team.h"
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateInterface];
}

#pragma mark - Interface Methods

- (void)updateInterface {
    if (self.teamsViewController.fetchedResultsController.fetchedObjects.count == 0) {
        self.teamsViewController.refresh();
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TeamsViewControllerEmbed]) {
        self.teamsViewController = (TBATeamsViewController *)segue.destinationViewController;
        self.teamsViewController.showSearch = YES;
        self.teamsViewController.persistenceController = self.persistenceController;
        
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
