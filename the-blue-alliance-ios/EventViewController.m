//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAImporter.h"
#import "TeamsTableViewController.h"
#import "EventInfoViewController.h"
#import "MatchResultsTableViewController.h"
#import "RankingsTableViewController.h"
#import "EventWebcastsViewController.h"

@interface EventViewController ()
@end

@implementation EventViewController

- (instancetype)initWithEvent:(Event *)event
{
    self = [super init];
    if(self) {
        self.event = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.event.friendlyName;
    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.event.managedObjectContext];
}

- (NSArray *)loadViewControllers
{
    // Create the different view controllers for the pages
    EventInfoViewController *eivc = [[EventInfoViewController alloc] init];
    eivc.title = @"Info";
    eivc.event = self.event;
    
    TeamsTableViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamsTableViewController"];
    tvc.eventFilter = self.event;
    tvc.disableSections = YES;
    tvc.context = self.event.managedObjectContext;
    
    MatchResultsTableViewController *mrvc = [[MatchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    mrvc.title = @"Results";
    mrvc.context = self.event.managedObjectContext;
    mrvc.event = self.event;
    
    RankingsTableViewController *rvc = [[RankingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    rvc.title = @"Rankings";
    rvc.context = self.event.managedObjectContext;
    rvc.event = self.event;
    
    EventWebcastsViewController *wvc = [[EventWebcastsViewController alloc] init];
    wvc.title = @"Webcasts";
    wvc.event = self.event;
    
    return @[eivc, tvc, mrvc, rvc, wvc];
}



@end
 