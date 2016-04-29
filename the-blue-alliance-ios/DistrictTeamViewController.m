//
//  DistrictTeamViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "DistrictTeamViewController.h"
#import "TBATeamAtDistrictSummaryViewController.h"
#import "TBADistrictRankingBreakdownViewController.h"
#import "EventTeamViewController.h"
#import "Team.h"
#import "District.h"
#import "DistrictRanking.h"
#import "EventPoints.h"

static NSString *const SummaryViewControllerEmbed   = @"SummaryViewControllerEmbed";
static NSString *const BreakdownViewControllerEmbed = @"BreakdownViewControllerEmbed";

static NSString *const EventTeamViewControllerSegue = @"EventTeamViewControllerSegue";

@class District, DistrictRanking, Team;

@interface DistrictTeamViewController ()

@property (nonatomic, strong) TBATeamAtDistrictSummaryViewController *summaryViewController;
@property (nonatomic, strong) TBADistrictRankingBreakdownViewController *rankingBreakdownViewController;

@end

@implementation DistrictTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.summaryViewController, self.rankingBreakdownViewController];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"Team %@", self.districtRanking.team.teamNumber];
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@ %@", self.district.year, [self.district.key uppercaseString]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SummaryViewControllerEmbed]) {
        self.summaryViewController = segue.destinationViewController;
        self.summaryViewController.districtRanking = self.districtRanking;
        
        __weak typeof(self) weakSelf = self;
        self.summaryViewController.eventPointsSelected = ^(EventPoints *eventPoints) {
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:eventPoints];
        };
    } else if ([segue.identifier isEqualToString:BreakdownViewControllerEmbed]) {
        self.rankingBreakdownViewController = segue.destinationViewController;
        self.rankingBreakdownViewController.districtRanking = self.districtRanking;
    } else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        EventPoints *eventPoints = (EventPoints *)sender;
        
        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.event = eventPoints.event;
        eventTeamViewController.team = self.districtRanking.team;
    }
}

@end
