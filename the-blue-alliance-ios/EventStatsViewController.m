//
//  EventStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventStatsViewController.h"
#import "TBATeamStatsViewController.h"
#import "TBAEventStatsViewController.h"
#import "EventTeamViewController.h"
#import "Event.h"

static NSString *const EventStatsViewControllerEmbed    = @"EventStatsViewControllerEmbed";
static NSString *const TeamStatsViewControllerEmbed     = @"TeamStatsViewControllerEmbed";

static NSString *const EventTeamViewControllerSegue     = @"EventTeamViewControllerSegue";

@interface EventStatsViewController ()

@property (nonatomic, strong) TBAEventStatsViewController *eventStatsViewController;
@property (nonatomic, strong) IBOutlet UIView *eventStatsView;

@property (nonatomic, strong) TBATeamStatsViewController *teamStatsViewController;
@property (nonatomic, strong) IBOutlet UIView *teamStatsView;

@end

@implementation EventStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.eventStatsViewController, self.teamStatsViewController];
    self.containerViews = @[self.eventStatsView, self.teamStatsView];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = @"Stats";
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TeamStatsViewControllerEmbed]) {
        self.teamStatsViewController = segue.destinationViewController;
        self.teamStatsViewController.event = self.event;
        
        __weak typeof(self) weakSelf = self;
        self.teamStatsViewController.teamSelected = ^(Team *team){
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:team];
        };
    } else if ([segue.identifier isEqualToString:EventStatsViewControllerEmbed]) {
        self.eventStatsViewController = segue.destinationViewController;
        self.eventStatsViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        Team *team = (Team *)sender;

        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.team = team;
        eventTeamViewController.event = self.event;
    }
}

@end
