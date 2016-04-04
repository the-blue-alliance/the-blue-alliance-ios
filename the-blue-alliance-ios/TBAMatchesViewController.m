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
                                                                      sectionNameKeyPath:@"compLevel"
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
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshMatches];
    };
}

#pragma mark - Data Methods

- (void)refreshMatches {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMatchesForEventKey:self.event.key withCompletionBlock:^(NSArray *matches, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload event matches"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Match insertMatchesWithModelMatches:matches forEvent:self.event inManagedObjectContext:self.persistenceController.managedObjectContext];
                [strongSelf.persistenceController save];
                [strongSelf.tableView reloadData];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAMatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.match = match;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No matches for this event"];
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.backgroundView.backgroundColor = [UIColor TBANavigationBarColor];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:16.0f];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Match *firstMatch = [[[self.fetchedResultsController sections][section] objects] firstObject];
    return [NSString stringWithFormat:@"%@ Matches", [firstMatch compLevelString]];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.matchSelected) {
        Match *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.matchSelected(match);
    }
}

@end
