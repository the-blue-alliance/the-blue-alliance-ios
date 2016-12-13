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
#import "Team+Fetch.h"

@interface TBATeamsViewController () <UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation TBATeamsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistentContainer) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [Team fetchRequest];
    if (self.event) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY events = %@", self.event]];
    }
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"teamNumber" ascending:YES]]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
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
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBATeamTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.event) {
            [strongSelf refreshEventTeams];
        } else {
            [strongSelf refreshAllTeams];
        }
    };
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.searchBar.tintColor = [UIColor primaryBlue];
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshEventTeams {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger currentRequest = [[TBAKit sharedKit] fetchTeamsForEventKey:self.event.key withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load teams for event"];
        }
        
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            Event *event = [backgroundContext objectWithID:strongSelf.event.objectID];
            [Team insertTeamsWithModelTeams:teams forEvent:event inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:currentRequest];
        }];
    }];
    [self addRequestIdentifier:currentRequest];
}

- (void)refreshAllTeams {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger currentRequest = [Team fetchAllTeamsWithTaskIdChange:^(NSUInteger newTaskId, NSArray *batchTeam) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf addRequestIdentifier:newTaskId];
        __block NSUInteger oldTaskId = currentRequest;
        currentRequest = newTaskId;
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            [Team insertTeamsWithModelTeams:batchTeam inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:oldTaskId];
        }];
    } withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:currentRequest];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load teams"];
        }
    }];
    [self addRequestIdentifier:currentRequest];
}

#pragma mark - TBA Table View Data Soruce

- (void)configureCell:(TBATeamTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.team = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No teams found"];
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
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    [self.tableView reloadData];
}

#pragma mark - Searching

- (NSPredicate *)predicateForSearchText:(NSString *)searchText {
    NSPredicate *searchPredicate;
    if (searchText && searchText.length) {
        if (self.event) {
            searchPredicate = [NSPredicate predicateWithFormat:@"ANY events = %@ AND (nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", self.event, searchText, searchText];
        } else {
            searchPredicate = [NSPredicate predicateWithFormat:@"(nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", searchText, searchText];
        }
    } else if (self.event) {
        searchPredicate = [NSPredicate predicateWithFormat:@"ANY events = %@", self.event];
    }
    return searchPredicate;
}

@end
