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

static NSString *const EventCellReuseIdentifier = @"EventCell";

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

- (void)clearFRC {
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    
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
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
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
 
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshEvents];
    };
}

#pragma mark - Data Methods

- (void)refreshEvents {
    if (!self.year || self.year.unsignedIntegerValue == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoDataViewWithText:@"No year selected"];
        });
        return;
    }

    [self updateRefresh:YES];
    __weak typeof(self) weakSelf = self;
    if (self.team) {
        __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForTeamKey:self.team.key andYear:self.year.unsignedIntegerValue withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeRequestIdentifier:request];
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf showNoDataViewWithText:@"Unable to load events for team"];
                });
            } else {
                NSArray *newEvents = [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.team addEvents:[NSSet setWithArray:newEvents]];
                [strongSelf.persistenceController save];
            }
        }];
        [self addRequestIdentifier:request];
    } else {
        __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForYear:self.year.unsignedIntegerValue withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeRequestIdentifier:request];
            
            if (error) {
                NSString *errorMessage = @"Unable to load events";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                    [strongSelf.persistenceController save];
                    if (self.eventsFetched) {
                        self.eventsFetched();
                    }
                });
            }
        }];
        [self addRequestIdentifier:request];
    }
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.backgroundView.backgroundColor = [UIColor TBANavigationBarColor];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:12.0f];
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
