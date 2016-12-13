//
//  TBARankingsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAEventRankingsViewController.h"
#import "TBAEventRankingTableViewCell.h"
#import "District.h"
#import "DistrictRanking.h"
#import "Event.h"
#import "EventRanking.h"
#import "EventPoints.h"

@implementation TBAEventRankingsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistentContainer) {
        return nil;
    }

    NSFetchRequest *fetchRequest = [EventRanking fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]];

    NSString *cacheName = [NSString stringWithFormat:@"%@_rankings", self.event.key];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
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
    self.cellIdentifier = RankCellReuseIdentifier;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBAEventRankingTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshRankings];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForEventKey:self.event.key withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload event rankings"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            Event *event = [backgroundContext objectWithID:strongSelf.event.objectID];
            [EventRanking insertEventRankingsWithEventRankings:rankings forEvent:event inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAEventRankingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.eventRanking = ranking;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No rankings for this event"];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.rankingSelected) {
        EventRanking *eventRanking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.rankingSelected(eventRanking);
    }
}

@end
