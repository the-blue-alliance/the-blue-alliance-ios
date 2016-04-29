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
@property (nonatomic, strong) IBOutlet UIView *awardsView;

@end

@implementation EventAwardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshViewControllers = @[self.awardsViewController];
    self.containerViews = @[self.awardsView];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = @"Awards";
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.event friendlyNameWithYear:YES]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:AwardsViewControllerEmbed]) {
        self.awardsViewController = segue.destinationViewController;
        self.awardsViewController.event = self.event;
    }
}

@end
