//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "OrderedDictionary.h"
#import "TBAApp.h"
#import "TBAKit.h"
#import "TBAImporter.h"
#import "HMSegmentedControl.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TeamTableViewCell.h"


static NSString *const TeamCellReuseIdentifier = @"Team Cell";


@interface TeamsTableViewController () <UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) NSMutableArray *filteredTeams;

@property (nonatomic, assign) NSUInteger currentRequestIdentifier;

// Ordered dict of "Groupings" (1-999, 1000-1999, 2000-2999, ...)
// Groupings have arrays of teams [1, 4, 5, 6, 7, ...]
@property (nonatomic, strong) OrderedDictionary *teamData;

@end


@implementation TeamsTableViewController

#pragma mark - Properities

- (UISearchController *)searchController {
    if (!_searchController) {
        UINavigationController *searchResultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamsNavigationController"];
        
        _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        
        _searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];

//        _searchController.searchBar.delegate = self;
    }
    return _searchController;
}

- (NSMutableArray *)filteredTeams {
    if (!_filteredTeams) {
        _filteredTeams = [[NSMutableArray alloc] init];
    }
    return _filteredTeams;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            [strongSelf refreshData];
        }
    };
    */
     
    [self fetchTeams];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    /*
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
    */
}


#pragma mark - Data Methods

- (OrderedDictionary *)groupTeams:(NSArray *)teams {
    MutableOrderedDictionary *mutableTeams = [[MutableOrderedDictionary alloc] init];

    for (Team *team in teams) {
        if ([[mutableTeams allKeys] containsObject:team.grouping_text]) {
            NSMutableArray *arr = [mutableTeams objectForKey:team.grouping_text];
            [arr addObject:team];
            
            [mutableTeams setValue:arr forKey:team.grouping_text];
        } else {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:team, nil];
            [mutableTeams setValue:arr forKey:team.grouping_text];
        }
    }
    return mutableTeams;
}

- (void)fetchTeams {
    self.teamData = nil;
    
    NSArray *teams = [Team fetchAllTeamsFromContext:[TBAApp managedObjectContext]];
    if (!teams || [teams count] == 0) {
        /*
        if (self.refresh) {
            self.refresh();
        }
        */
    } else {
        self.teamData = [self groupTeams:teams];
    }
}

- (void)getTeamsForPage:(int)page {
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"teams/%@", @(page)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;
        
        if (error) {
            NSLog(@"Error loading teams: %@", error.localizedDescription);
        }
        if (!error && [objects isKindOfClass:[NSArray class]] && [objects count] > 0) {
            [TBAImporter importTeams:objects];
        }

        if ([objects isKindOfClass:[NSArray class]]) {
            if ([objects count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self updateRefreshBarButtonItem:NO];

                    [self fetchTeams];
                    [self updateInterface];
                });
            } else {
                [self getTeamsForPage:page + 1];
            }
        }
    }];
}

- (void)refreshData {
    [self getTeamsForPage:0];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self updateInterface];
}

- (void)updateInterface {
    [self.tableView reloadData];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.filteredTeams) {
        return 0;
    }
    return [self.filteredTeams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];

    cell.numberLabel.text = [team.team_number stringValue];
    cell.nameLabel.text = team.nickname;
    cell.locationLabel.text = team.location;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];
    NSLog(@"Selected team: %@", team.team_number);
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
//    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}


#pragma mark - Navigation

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TeamsCollectionViewControllerEmbedSegue"]) {
        TeamsCollectionViewController *teamsCollectionViewController = segue.destinationViewController;
        teamsCollectionViewController.collectionView.delegate = self;
        self.teamsCollectionViewController = teamsCollectionViewController;
    }
}
*/

@end
