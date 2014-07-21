//
//  TeamDetailViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TeamInfoViewController.h"

@interface TeamDetailViewController ()
@property (nonatomic, strong) Team *team;
@end

@implementation TeamDetailViewController

- (instancetype)initWithTeam:(Team *)team
{
    self = [super init];
    if(self) {
        self.team = team;
    }
    return self;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"FRC Team %d", self.team.team_numberValue];
}

- (NSArray *)loadViewControllers
{
    // Create the different view controllers for the pages
    TeamInfoViewController *tivc = [[TeamInfoViewController alloc] init];
    tivc.team = self.team;

    
    return @[tivc];
}


@end
