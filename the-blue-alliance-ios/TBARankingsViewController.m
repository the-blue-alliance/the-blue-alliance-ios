//
//  TBARankingsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARankingsViewController.h"
#import "TBARankingTableViewCell.h"
#import "District.h"
#import "Event.h"

static NSString *const RankCellReuseIdentifier  = @"RankCell";

@implementation TBARankingsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest;
    NSPredicate *predicate;
    NSString *cacheName;
    if (self.event) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventRanking"];
        predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
        cacheName = [NSString stringWithFormat:@"%@_rankings", self.event.key];
    } else if (self.district) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DistrictRanking"];
        predicate = [NSPredicate predicateWithFormat:@"district == %@", self.district];
        cacheName = [NSString stringWithFormat:@"%@_rankings", self.district.key];
    }
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *rankSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    [fetchRequest setSortDescriptors:@[rankSortDescriptor]];
    
    // Need a cache name here
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:cacheName];
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
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    } else {
        // TODO: Show no data screen;
        count = 0;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBARankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RankCellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TBARankingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.district) {
        DistrictRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.districtRanking = ranking;
    } else if (self.event) {
        EventRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.eventRanking = ranking;
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.rankingSelected) {
        id ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.rankingSelected(ranking);
    }
}

@end
