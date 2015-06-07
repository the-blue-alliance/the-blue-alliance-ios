//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "OrderedDictionary.h"
#import "TBAImporter.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TeamTableViewCell.h"


static NSString *const TeamCellReuseIdentifier = @"Team Cell";


@interface TeamsViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *filteredTeams;

@end


@implementation TeamsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            [strongSelf refreshData];
        }
    };
    
    self.filteredTeams = [[NSMutableArray alloc] init];
    
    [self fetchTeams];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}


#pragma mark - Data Methods

- (void)fetchTeams {
    self.filteredTeams = @[];
    
    __weak typeof(self) weakSelf = self;
    [Team fetchAllTeamsFromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch teams locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!teams || [teams count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.filteredTeams = teams;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}

- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [Team fetchAllTeamsWithTaskIdChange:^(NSUInteger newTaskId, NSArray *batchTeam) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentRequestIdentifier = newTaskId;

        NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [tmpContext setParentContext:strongSelf.persistenceController.managedObjectContext];
        [tmpContext performBlock:^{
            [Team insertTeamsWithModelTeams:batchTeam inManagedObjectContext:tmpContext];
            [tmpContext save:nil];
        }];
    } withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching teams" andMessage:error.localizedDescription];
        } else {
            [strongSelf fetchTeams];
            [strongSelf.persistenceController save];
        }
    }];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.filteredTeams) {
        // TODO: Show no data screen
        return 0;
    }
    return [self.filteredTeams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];

    cell.numberLabel.text = [NSString stringWithFormat:@"%lld", team.teamNumber];
    cell.nameLabel.text = team.nickname;
    cell.locationLabel.text = team.location;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];
    NSLog(@"Selected team: %lld", team.teamNumber);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    __weak typeof(self) weakSelf = self;
    [Team fetchTeamsWithPredicate:[self predicateForSearchText:searchText] fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to search teams" andMessage:error.localizedDescription];
        } else {
            strongSelf.filteredTeams = teams;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}
 
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


#pragma mark - Searching

- (NSPredicate *)predicateForSearchText:(NSString *)searchText {
    NSPredicate *searchPredicate;
    if (searchText && searchText.length) {
        searchPredicate = [NSPredicate predicateWithFormat:@"(nickname contains[cd] %@ OR teamNumber beginswith[cd] %@)", searchText, searchText];
    }
    return searchPredicate;
}


@end
