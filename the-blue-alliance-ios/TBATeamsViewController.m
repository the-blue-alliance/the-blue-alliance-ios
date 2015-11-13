//
//  TBATeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATeamsViewController.h"
#import "TBATeamTableViewCell.h"
#import "Event.h"
#import "Team.h"

static NSString *const TeamCellReuseIdentifier = @"TeamCell";

@implementation TBATeamsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    if (self.event) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY events = %@", self.event]];
    }
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"teamNumber" ascending:YES]]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
    self.cellIdentifier = TeamCellReuseIdentifier;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.showSearch) {
        [self hideSearchBar];
    }
}

#pragma mark - Private Methods

- (NSString *)cacheName {
    NSString *cacheName;
    if (self.event) {
        cacheName = [NSString stringWithFormat:@"%@_teams", self.event.key];
    } else {
        cacheName = @"teams";
    }
    return cacheName;
}

#pragma mark - TBA Table View Data Soruce

- (void)configureCell:(TBATeamTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.team = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.teamSelected) {
        return;
    }
    
    Team *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.teamSelected(team);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchBar && [self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Search Bar Delegate

- (void)hideSearchBar {
    [self.tableView setContentOffset:CGPointMake(0, CGRectGetHeight(self.searchBar.frame) - [self.topLayoutGuide length]) animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    
    [self filterContentForSearchText:@""];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *predicate = [self predicateForSearchText:searchText];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [NSFetchedResultsController deleteCacheWithName:[self cacheName]];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    [self.fetchedResultsController.delegate controllerDidChangeContent:self.fetchedResultsController];
    [self.tableView reloadData];
}

#pragma mark - Searching

- (NSPredicate *)predicateForSearchText:(NSString *)searchText {
    NSPredicate *searchPredicate;
    if (searchText && searchText.length) {
        searchPredicate = [NSPredicate predicateWithFormat:@"(nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", searchText, searchText];
    }
    return searchPredicate;
}

@end
