//
//  TBAMyTBATableViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAMyTBATableViewController.h"
#import "Favorite.h"
#import "Subscription.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Match.h"
#import "Match+Fetch.h"
#import "TBAEventTableViewCell.h"
#import "TBATeamTableViewCell.h"
#import "TBAMatchTableViewCell.h"
#import <AppAuth/AppAuth.h>

@implementation TBAMyTBATableViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (!self.persistenceController) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self.modelClass)];
    
    NSSortDescriptor *typeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modelType" ascending:YES];
    [fetchRequest setSortDescriptors:@[typeSortDescriptor]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:@"modelType"
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
    
    // Register event cell, team cell, match cell
    UINib *eventCellNib = [UINib nibWithNibName:NSStringFromClass([TBAEventTableViewCell class]) bundle:nil];
    [self.tableView registerNib:eventCellNib forCellReuseIdentifier:EventCellReuseIdentifier];
    
    UINib *teamCellNib = [UINib nibWithNibName:NSStringFromClass([TBATeamTableViewCell class]) bundle:nil];
    [self.tableView registerNib:teamCellNib forCellReuseIdentifier:TeamCellReuseIdentifier];
    
    UINib *matchCellNib = [UINib nibWithNibName:NSStringFromClass([TBAMatchTableViewCell class]) bundle:nil];
    [self.tableView registerNib:matchCellNib forCellReuseIdentifier:MatchCellReuseIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshData];
    };
}


#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshData {
    if (![TBAKit sharedKit].myTBAAuthentication) {
        return;
    }
    
    if (self.modelClass == [Favorite class]) {
        [self refreshFavorites];
    } else if (self.modelClass == [Subscription class]) {
        [self refreshSubscriptions];
    }
}

- (void)refreshSubscriptions {
    __weak typeof(self) weakSelf = self;
    __block GTMSessionFetcher *fetcher = [[TBAKit sharedKit] fetchSubscriptionsWithCompletionBlock:^(NSArray<TBASubscription *> *subscriptions, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            if ([error.domain isEqual:OIDOAuthTokenErrorDomain]) {
                [strongSelf showErrorAlertWithMessage:@"Unable to load subscriptions - please sign out and sign back in to your account"];
            } else {
                [strongSelf showErrorAlertWithMessage:@"Unable to load subscriptions"];
            }
            NSLog(@"Error: %@", error);
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Subscription insertSubscriptionsWithModelSubscriptions:subscriptions inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeSessionFetcher:fetcher];
        }];
    }];
    [self addSessionFetcher:fetcher];
}

- (void)refreshFavorites {
    __weak typeof(self) weakSelf = self;
    __block GTMSessionFetcher *fetcher = [[TBAKit sharedKit] fetchFavoritesWithCompletionBlock:^(NSArray<TBAFavorite *> *favorites, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            if ([error.domain isEqual:OIDOAuthTokenErrorDomain]) {
                [strongSelf showErrorAlertWithMessage:@"Unable to load favorites - please sign out and sign back in to your account"];
            } else {
                [strongSelf showErrorAlertWithMessage:@"Unable to load favorites"];
            }
            NSLog(@"Error: %@", error);
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Favorite insertFavoritesWithModelFavorites:favorites inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeSessionFetcher:fetcher];
        }];
    }];
    [self addSessionFetcher:fetcher];
}

#pragma mark - Private Methods

- (NSString *)pluralNameForModalClass {
    return [NSString stringWithFormat:@"%@s", NSStringFromClass(self.modelClass).lowercaseString];
}

#pragma mark - Table View Data Source

// Copied and pasted numberOfSectionsInTableView: and tableView:numberOfRowsInSection: from TBAContainerTableViewController
// We want to have the same logic for # of rows and # of cells, but we don't want to use the configureCell method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        sections = self.fetchedResultsController.sections.count;
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        rows = [sectionInfo numberOfObjects];
        if (!rows || (rows && rows == 0 && self.tbaDelegate)) {
            [self.tbaDelegate showNoDataView];
        } else {
            [self hideNoDataView];
        }
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Favorite *favorite;
    Subscription *subscription;
    if (self.modelClass == [Favorite class]) {
        favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if (self.modelClass == [Subscription class]) {
        subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell;
    if (favorite.modelType.integerValue == TBAMyTBAModelTypeEvent || subscription.modelType.integerValue == TBAMyTBAModelTypeEvent) {
        NSString *eventKey = favorite ? favorite.modelKey : subscription.modelKey;
        if ([eventKey containsString:@"*"]) {
            // TODO: Handle this
        }
        Event *event = [Event fetchEventForKey:eventKey fromContext:self.persistenceController.managedObjectContext];
        
        TBAEventTableViewCell *eventCell = [tableView dequeueReusableCellWithIdentifier:EventCellReuseIdentifier forIndexPath:indexPath];
        eventCell.event = event;
        eventCell.settingsButton.hidden = NO;
        
        __weak typeof(self) weakSelf = self;
        eventCell.settingsButtonTapped = ^{
            if (weakSelf.eventSettingsTapped) {
                weakSelf.eventSettingsTapped(favorite ? favorite : subscription, event);
            }
        };

        cell = eventCell;
    } else if (favorite.modelType.integerValue == TBAMyTBAModelTypeTeam || subscription.modelType.integerValue == TBAMyTBAModelTypeTeam) {
        NSString *teamKey = favorite ? favorite.modelKey : subscription.modelKey;
        Team *team = [Team fetchTeamForKey:teamKey fromContext:self.persistenceController.managedObjectContext];
        
        TBATeamTableViewCell *teamCell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
        teamCell.team = team;
        teamCell.settingsButton.hidden = NO;
        
        __weak typeof(self) weakSelf = self;
        teamCell.settingsButtonTapped = ^{
            if (weakSelf.teamSettingsTapped) {
                weakSelf.teamSettingsTapped(favorite ? favorite : subscription, team);
            }
        };
        
        cell = teamCell;
    } else if (favorite.modelType.integerValue == TBAMyTBAModelTypeMatch || subscription.modelType.integerValue == TBAMyTBAModelTypeMatch) {
        NSString *matchKey = favorite ? favorite.modelKey : subscription.modelKey;
        Match *match = [Match fetchMatchForKey:matchKey fromContext:self.persistenceController.managedObjectContext];
        
        TBAMatchTableViewCell *matchCell = [tableView dequeueReusableCellWithIdentifier:MatchCellReuseIdentifier forIndexPath:indexPath];
        matchCell.match = match;
        
        cell = matchCell;
    }
    return cell;
}

#pragma mark - TBA Table View Data Source

- (void)showNoDataView {
    [self showNoDataViewWithText:[NSString stringWithFormat:@"No %@ found", [self pluralNameForModalClass]]];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Favorite *favorite;
    Subscription *subscription;
    if (self.modelClass == [Favorite class]) {
        favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if (self.modelClass == [Subscription class]) {
        subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    if (favorite.modelType.integerValue == TBAMyTBAModelTypeEvent || subscription.modelType.integerValue == TBAMyTBAModelTypeEvent) {
        NSString *eventKey = favorite ? favorite.modelKey : subscription.modelKey;
        // Don't push for * events, since it's not an event
        if ([eventKey containsString:@"*"]) {
            return;
        }
        Event *event = [Event fetchEventForKey:eventKey fromContext:self.persistenceController.managedObjectContext];
        
        if (self.eventSelected) {
            self.eventSelected(event);
        }
    } else if (favorite.modelType.integerValue == TBAMyTBAModelTypeTeam || subscription.modelType.integerValue == TBAMyTBAModelTypeTeam) {
        NSString *teamKey = favorite ? favorite.modelKey : subscription.modelKey;
        Team *team = [Team fetchTeamForKey:teamKey fromContext:self.persistenceController.managedObjectContext];
        if (self.teamSelected) {
            self.teamSelected(team);
        }
    } else if (favorite.modelType.integerValue == TBAMyTBAModelTypeMatch || subscription.modelType.integerValue == TBAMyTBAModelTypeMatch) {
        NSString *matchKey = favorite ? favorite.modelKey : subscription.modelKey;
        Match *match = [Match fetchMatchForKey:matchKey fromContext:self.persistenceController.managedObjectContext];
        if (self.matchSelected) {
            self.matchSelected(match);
        }
    }
}

@end
