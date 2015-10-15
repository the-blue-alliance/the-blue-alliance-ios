//
//  TBAMatchesViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMatchesViewController.h"
#import "TBAMatchTableViewCell.h"
#import "Event.h"
#import "Match.h"

static NSString *const MatchCellReuseIdentifier = @"MatchCell";

@implementation TBAMatchesViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *compLevelSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"compLevel" ascending:YES];
    NSSortDescriptor *setNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"setNumber" ascending:YES];
    NSSortDescriptor *matchNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"matchNumber" ascending:YES];
    [fetchRequest setSortDescriptors:@[compLevelSortDescriptor, setNumberSortDescriptor, matchNumberSortDescriptor]];
    
    // Need a cache name here
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:[NSString stringWithFormat:@"%@_matches", self.event.key]];
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
    self.cellIdentifier = MatchCellReuseIdentifier;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAMatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.match = match;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.matchSelected) {
        Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.matchSelected(match);
    }
}

@end
