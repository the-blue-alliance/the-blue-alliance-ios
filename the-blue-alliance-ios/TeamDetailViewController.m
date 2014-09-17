//
//  TeamDetailViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TeamInfoViewController.h"
#import "EventsTableViewController.h"
#import "TBAImporter.h"

@interface TeamDetailViewController ()
@end

@implementation TeamDetailViewController

- (void)setTeam:(Team *)team
{
    _team = team;
    
    self.title = [NSString stringWithFormat:@"FRC Team %d", self.team.team_numberValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#warning TODO: Replace with dynamic year
    [TBAImporter linkEventsToTeam:self.team forYear:2014 usingManagedObjectContext:self.team.managedObjectContext];
    [TBAImporter linkMediaToTeam:self.team forYear:2014 usingManagedObjectContext:self.team.managedObjectContext];
}

- (NSArray *)loadViewControllers
{
    // Create the different view controllers for the pages
    TeamInfoViewController *tivc = [[TeamInfoViewController alloc] init];
    tivc.title = @"Info";
    tivc.team = self.team;

    EventsTableViewController *etvc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventsTableViewController"];
    etvc.teamFilter = self.team;
    etvc.context = self.team.managedObjectContext;
    etvc.title = @"Events";
    
    return @[tivc, etvc];
}


@end
