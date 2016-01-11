//
//  TBAAlliancesTableViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAlliancesViewController.h"
#import "Event.h"
#import "EventAlliance.h"
#import "TBAAllianceCell.h"

static NSString *const AllianceCellReuseIdentifier  = @"AllianceCell";

@implementation TBAAlliancesViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventAlliance"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *allianceNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"allianceNumber" ascending:YES];
    [fetchRequest setSortDescriptors:@[allianceNumberSortDescriptor]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
    self.cellIdentifier = AllianceCellReuseIdentifier;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAAllianceCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventAlliance *alliance = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.eventAlliance = alliance;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
