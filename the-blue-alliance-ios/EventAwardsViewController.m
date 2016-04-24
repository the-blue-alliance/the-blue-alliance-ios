//
//  EventAwardsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventAwardsViewController.h"
#import "TBAAwardsViewController.h"
#import "Event.h"

static NSString *const AwardsViewControllerEmbed = @"AwardsViewControllerEmbed";

@interface EventAwardsViewController ()

@property (nonatomic, strong) TBAAwardsViewController *awardsViewController;

@end

@implementation EventAwardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Awards", [self.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:AwardsViewControllerEmbed]) {
        self.awardsViewController = segue.destinationViewController;
        self.awardsViewController.persistenceController = self.persistenceController;
        self.awardsViewController.event = self.event;
    }
}

@end
