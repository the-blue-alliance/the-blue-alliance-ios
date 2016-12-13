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
    
    if (!self.persistentContainer) {
        return nil;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self.modelClass)];
    
    NSSortDescriptor *typeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modelType" ascending:YES];
    [fetchRequest setSortDescriptors:@[typeSortDescriptor]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
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
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            [strongSelf setupMyTBAModels:subscriptions inContext:backgroundContext withCompletionBlock:^(NSArray<TBAMyTBAModel *> *models) {
                [Subscription insertSubscriptionsWithModelSubscriptions:subscriptions inManagedObjectContext:backgroundContext];
                [backgroundContext save:nil];
                [strongSelf removeSessionFetcher:fetcher];
            }];
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
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            [strongSelf setupMyTBAModels:favorites inContext:backgroundContext withCompletionBlock:^(NSArray<TBAMyTBAModel *> *models) {
                [Favorite insertFavoritesWithModelFavorites:favorites inManagedObjectContext:backgroundContext];
                [backgroundContext save:nil];
                [strongSelf removeSessionFetcher:fetcher];
                
            }];
        }];
    }];
    [self addSessionFetcher:fetcher];
}

- (void)setupMyTBAModels:(NSArray<TBAMyTBAModel *> *)models inContext:(NSManagedObjectContext *)context withCompletionBlock:(void (^)(NSArray<TBAMyTBAModel *> *models))completion; {
    dispatch_group_t group = dispatch_group_create();

    NSMutableArray<TBAMyTBAModel *> *modelsToInsert = [models mutableCopy];
    for (TBAMyTBAModel *model in models) {
        TBAMyTBAModelType type = model.modelType;
        NSString *key = model.modelKey;
        
        if (type == TBAMyTBAModelTypeTeam) {
            dispatch_group_enter(group);
            [Team fetchTeamWithKey:key inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull team, NSError * _Nonnull error) {
                if (!team) {
                    [modelsToInsert removeObject:model];
                }
                dispatch_group_leave(group);
            }];
        } else if (type == TBAMyTBAModelTypeEvent) {
            dispatch_group_enter(group);
            [Event fetchEventWithKey:key inManagedObjectContext:context withCompletionBlock:^(Event * _Nullable event, NSError * _Nullable error) {
                if (!event) {
                    [modelsToInsert removeObject:model];
                }
                dispatch_group_leave(group);
            }];
        } else if (type == TBAMyTBAModelTypeMatch) {
            dispatch_group_enter(group);
            [Match fetchMatchWithKey:key inManagedObjectContext:context withCompletionBlock:^(Match * _Nullable match, NSError * _Nullable error) {
                if (!match) {
                    [modelsToInsert removeObject:model];
                }
                dispatch_group_leave(group);
            }];
        }
    }

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (completion) {
            completion(modelsToInsert);
        }
    });
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
    TBAMyTBAModelType modelType;
    if (self.modelClass == [Favorite class]) {
        favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
        modelType = favorite.modelType.integerValue;
    } else if (self.modelClass == [Subscription class]) {
        subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
        modelType = subscription.modelType.integerValue;
    }
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    UITableViewCell *cell;
    if (modelType == TBAMyTBAModelTypeEvent) {
        NSString *eventKey = favorite ? favorite.modelKey : subscription.modelKey;
        if ([eventKey containsString:@"*"]) {
            // TODO: Handle this
        }
        Event *event = [Event findOrFetchEventWithKey:eventKey inManagedObjectContext:context];
        
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
    } else if (modelType == TBAMyTBAModelTypeTeam) {
        NSString *teamKey = favorite ? favorite.modelKey : subscription.modelKey;
        Team *team = [Team findOrFetchTeamWithKey:teamKey inManagedObjectContext:context];
        
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
    } else if (modelType == TBAMyTBAModelTypeMatch) {
        NSString *matchKey = favorite ? favorite.modelKey : subscription.modelKey;
        Match *match = [Match findOrFetchMatchWithKey:matchKey inManagedObjectContext:context];
        
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
    TBAMyTBAModelType modelType;
    if (self.modelClass == [Favorite class]) {
        favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
        modelType = favorite.modelType.integerValue;
    } else if (self.modelClass == [Subscription class]) {
        subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
        modelType = subscription.modelType.integerValue;
    }

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (modelType == TBAMyTBAModelTypeEvent) {
        NSString *eventKey = favorite ? favorite.modelKey : subscription.modelKey;
        // Don't push for * events, since it's not an event
        if ([eventKey containsString:@"*"]) {
            return;
        }
        Event *event = [Event findOrFetchEventWithKey:eventKey inManagedObjectContext:context];
        if (self.eventSelected) {
            self.eventSelected(event);
        }
    } else if (modelType == TBAMyTBAModelTypeTeam) {
        NSString *teamKey = favorite ? favorite.modelKey : subscription.modelKey;
        Team *team = [Team findOrFetchInContext:context matchingPredicate:[NSPredicate predicateWithFormat:@"key == %@", teamKey]];
        if (self.teamSelected) {
            self.teamSelected(team);
        }
    } else if (modelType == TBAMyTBAModelTypeMatch) {
        NSString *matchKey = favorite ? favorite.modelKey : subscription.modelKey;
        Match *match = [Match findOrFetchMatchWithKey:matchKey inManagedObjectContext:context];
        if (self.matchSelected) {
            self.matchSelected(match);
        }
    }
}

@end
