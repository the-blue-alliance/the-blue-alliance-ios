//
//  EventAlliancesViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventAlliancesViewController.h"
#import "TBAAlliancesViewController.h"
#import "Event.h"

static NSString *const AlliancesViewControllerEmbed = @"AlliancesViewControllerEmbed";

@interface EventAlliancesViewController ()

@property (nonatomic, strong) TBAAlliancesViewController *alliancesViewController;

@end

@implementation EventAlliancesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Alliances", [self.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:AlliancesViewControllerEmbed]) {
        self.alliancesViewController = segue.destinationViewController;
        self.alliancesViewController.persistenceController = self.persistenceController;
        self.alliancesViewController.event = self.event;
    }
}

@end
