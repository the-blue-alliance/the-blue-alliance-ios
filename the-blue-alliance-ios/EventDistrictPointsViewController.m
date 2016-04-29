//
//  EventDistrictPointsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventDistrictPointsViewController.h"
#import "TBAPointsViewController.h"
#import "Event.h"

static NSString *const DistrictPointsViewControllerEmbed = @"DistrictPointsViewControllerEmbed";

@interface EventDistrictPointsViewController ()

@property (nonatomic, strong) TBAPointsViewController *districtPointsViewController;

@end

@implementation EventDistrictPointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.districtPointsViewController];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = @"District Points";
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DistrictPointsViewControllerEmbed]) {
        self.districtPointsViewController = segue.destinationViewController;
        self.districtPointsViewController.event = self.event;
    }
}

@end
