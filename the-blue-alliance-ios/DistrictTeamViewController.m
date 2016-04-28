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

typedef NS_ENUM(NSInteger, TBADistrictTeamSegment) {
    TBADistrictTeamSegmentSummary = 0,
    TBADistrictTeamSegmentBreakdown
};

@class District, DistrictRanking, Team;

@interface DistrictTeamViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBATeamAtDistrictSummaryViewController *summaryViewController;
@property (nonatomic, strong) IBOutlet UIView *summaryView;

@property (nonatomic, strong) TBADistrictRankingBreakdownViewController *rankingBreakdownViewController;
@property (nonatomic, strong) IBOutlet UIView *breakdownView;

@end

@implementation DistrictTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
}

#pragma mark - Private Methods

- (void)cancelRefreshes {
    NSArray *refreshTVCs = @[self.summaryViewController, self.rankingBreakdownViewController];
    for (TBARefreshTableViewController *refreshTVC in refreshTVCs) {
        if (refreshTVC) {
            [refreshTVC cancelRefresh];
        }
    }
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"Team %@", self.districtRanking.team.teamNumber];
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@ %@", self.district.year, [self.district.key uppercaseString]];
}

- (void)updateInterface {
    if (self.segmentedControl.selectedSegmentIndex == TBADistrictTeamSegmentSummary) {
        [self showView:self.summaryView];
    } else if (self.segmentedControl.selectedSegmentIndex == TBADistrictTeamSegmentBreakdown) {
        [self showView:self.breakdownView];
    }
}

- (void)showView:(UIView *)showView {
    for (UIView *view in @[self.summaryView, self.breakdownView]) {
        view.hidden = (showView == view ? NO : YES);
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self cancelRefreshes];
    [self updateInterface];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SummaryViewControllerEmbed]) {
        self.summaryViewController = segue.destinationViewController;
        self.summaryViewController.persistenceController = self.persistenceController;
        self.summaryViewController.districtRanking = self.districtRanking;
        
        __weak typeof(self) weakSelf = self;
        self.summaryViewController.eventPointsSelected = ^(EventPoints *eventPoints) {
            [weakSelf performSegueWithIdentifier:EventTeamViewControllerSegue sender:eventPoints];
        };
    } else if ([segue.identifier isEqualToString:BreakdownViewControllerEmbed]) {
        self.rankingBreakdownViewController = segue.destinationViewController;
        self.rankingBreakdownViewController.persistenceController = self.persistenceController;
        self.rankingBreakdownViewController.districtRanking = self.districtRanking;
    } else if ([segue.identifier isEqualToString:EventTeamViewControllerSegue]) {
        EventPoints *eventPoints = (EventPoints *)sender;
        
        EventTeamViewController *eventTeamViewController = segue.destinationViewController;
        eventTeamViewController.persistenceController = self.persistenceController;
        eventTeamViewController.event = eventPoints.event;
        eventTeamViewController.team = self.districtRanking.team;
    }
}

@end
