//
//  TBATeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATeamsViewController.h"
#import "TBATeamTableViewCell.h"
#import "Team.h"
#import "Team+Fetch.h"

static NSString *const TeamCellReuseIdentifier = @"TeamCell";

@interface TBATeamsViewController ()

@property (nonatomic, strong) NSArray *filteredTeams;

@end

@implementation TBATeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleInterface];
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
    NSUInteger count = 0;
    if (self.filteredTeams) {
        count = [self.filteredTeams count];
    } else if ([self.teams count]) {
        count = [self.teams count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBATeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];

    cell.team = [self teamForIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.teamSelected) {
        return;
    }
    
    Team *team = [self teamForIndex:indexPath.row];
    self.teamSelected(team);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchBar && [self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *predicate = [self predicateForSearchText:searchText];
    if (predicate) {
        self.filteredTeams = [self.teams filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredTeams = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
        searchPredicate = [NSPredicate predicateWithFormat:@"(nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", searchText, searchText];
    }
    return searchPredicate;
}

#pragma mark - Private Methods

- (Team *)teamForIndex:(NSUInteger)index {
    Team *team;
    if (self.filteredTeams) {
        team = [self.filteredTeams objectAtIndex:index];
    } else if (self.teams) {
        team = [self.teams objectAtIndex:index];
    }
    return team;
}

@end
