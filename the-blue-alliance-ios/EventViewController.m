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

@interface EventViewController ()
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation EventViewController

- (instancetype)initWithEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if(self) {
        self.event = event;
        self.context = context;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.event.friendlyName;
    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.context];
    
}

- (NSArray *)loadViewControllers
{
    // Create the different view controllers for the pages
    EventInfoViewController *eivc = [[EventInfoViewController alloc] init];
    eivc.event = self.event;
    
    TeamsTableViewController *tvc = [[TeamsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tvc.eventFilter = self.event;
    tvc.disableSections = YES;
    tvc.context = self.context;
    
    MatchResultsTableViewController *mrvc = [[MatchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    mrvc.context = self.context;
    mrvc.event = self.event;
    
    RankingsTableViewController *rvc = [[RankingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    rvc.context = self.context;
    rvc.event = self.event;
    
    return @[eivc, tvc, mrvc, rvc];
}



@end
 