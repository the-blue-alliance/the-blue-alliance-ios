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

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            TBAMatchTableViewCell *cell = (TBAMatchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    } else {
        // TODO: Show no data screen;
        count = 0;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAMatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MatchCellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

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
