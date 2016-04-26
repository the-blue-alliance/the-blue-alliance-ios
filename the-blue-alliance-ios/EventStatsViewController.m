//
//  EventStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventStatsViewController.h"
#import "Event.h"

@interface EventStatsViewController ()

@end

@implementation EventStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationTitleLabel.text = @"Stats";
    self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"@ %@", [self.event friendlyNameWithYear:YES]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
