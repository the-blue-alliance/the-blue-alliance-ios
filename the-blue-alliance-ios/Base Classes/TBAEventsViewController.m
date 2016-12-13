//
//  TBAEventsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAEventsViewController.h"
#import "TBAEventTableViewCell.h"
#import "District.h"
#import "Event.h"
#import "Team.h"
#import "UIColor+TBAColors.h"

@implementation TBAEventsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (void)setYear:(NSNumber *)year {
    _year = year;
    
    [self clearFRC];
}

- (void)setWeek:(NSNumber *)week {
    _week = week;

    [self clearFRC];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistentContainer) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [Event fetchRequest];
    
    NSSortDescriptor *firstSortDescriptor;
    NSString *sectionNameKeyPath;
    if (self.district) {
        firstSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES];
        sectionNameKeyPath = @"week";
    } else {
        firstSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hybridType" ascending:YES];
        sectionNameKeyPath = @"hybridType";
    }
    [fetchRequest setSortDescriptors:@[firstSortDescriptor, [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSPredicate *predicate;
    if (self.week) {
        predicate = [NSPredicate predicateWithFormat:@"year == %@ AND week == %@", self.year, self.week];
    } else if (self.team && self.year) {
        predicate = [NSPredicate predicateWithFormat:@"year == %@ AND ANY teams == %@", self.year, self.team];
    } else if (self.district) {
        predicate = [NSPredicate predicateWithFormat:@"year == %@ AND eventDistrictString == %@", self.district.year, self.district.name];
    } else {
        // TODO: Abandon ship and show a no data view
        return nil;
    }
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
                                                                      sectionNameKeyPath:sectionNameKeyPath
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
    self.cellIdentifier = EventCellReuseIdentifier;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBAEventTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!self.year || self.year == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showNoDataViewWithText:@"No year selected"];
            });
            return;
        } else {
            if (strongSelf.team) {
                [strongSelf refreshTeamEvents];
            } else if (strongSelf.district) {
                [strongSelf refreshDistrictEvents];
            } else {
                [strongSelf refreshAllEvents];
            }
        }
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshTeamEvents {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForTeamKey:self.team.key andYear:self.year.integerValue withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load events for team"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            Team *team = [backgroundContext objectWithID:strongSelf.team.objectID];
            
            NSArray *newEvents = [Event insertEventsWithModelEvents:events inManagedObjectContext:backgroundContext];
            [team setEvents:[NSSet setWithArray:newEvents] forYear:strongSelf.year];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

- (void)refreshDistrictEvents {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForDistrictShort:self.district.key forYear:self.year.integerValue withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load events for district"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            [Event insertEventsWithModelEvents:events inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

- (void)refreshAllEvents {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForYear:self.year.integerValue withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load events"];
        }
        
        __block NSArray<Event *> *localEvents;
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            localEvents = [Event insertEventsWithModelEvents:events inManagedObjectContext:backgroundContext];
            NSError *someOtherError;
            [backgroundContext save:&someOtherError];
            NSLog(@"ERROR: %@", someOtherError);
            [strongSelf removeRequestIdentifier:request];
            
            for (Event *event in localEvents) {
                [strongSelf fetchTeamsForEvent:event];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && self.eventsFetched) {
                    self.eventsFetched();
                }
            });
        }];
    }];
    [self addRequestIdentifier:request];
}

- (void)fetchTeamsForEvent:(Event *)event {
    __weak typeof(self) weakSelf = self;
    // Don't add the request identifier - we can update teams in the background silently
    [[TBAKit sharedKit] fetchTeamsForEventKey:event.key withCompletionBlock:^(NSArray *teams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            return;
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            Event *e = [backgroundContext objectWithID:event.objectID];
            [Team insertTeamsWithModelTeams:teams forEvent:e inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
        }];
    }];
}

#pragma mark - Table View Delgate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.backgroundView.backgroundColor = [UIColor primaryDarkBlue];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:14.0f];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Event *firstEvent = [[[self.fetchedResultsController sections][section] objects] firstObject];

    NSString *title;
    if (self.district) {
        title = [NSString stringWithFormat:@"Week %@ Events", firstEvent.week.stringValue];
    } else {
        title = [firstEvent hybridString];
    }
    return title;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAEventTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.event = event;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No events found"];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.eventSelected) {
        return;
    }
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.eventSelected(event);
}

@end
