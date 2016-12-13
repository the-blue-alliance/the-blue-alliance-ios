//
//  TBATeamAtEventStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamAtEventStatsViewController.h"
#import "TBASummaryTableViewCell.h"
#import "EventTeamStat.h"
#import "Event.h"

@implementation TBATeamAtEventStatsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (!self.persistentContainer) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [EventTeamStat fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@", self.event, self.team];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"statType" ascending:YES]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
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
    self.cellIdentifier = SummaryCellReuseIdentifier;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBASummaryTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshEventStats];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshEventStats {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchStatsForEventKey:self.event.key withCompletionBlock:^(NSDictionary *stats, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team stats"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            Event *event = [backgroundContext objectWithID:strongSelf.event.objectID];
            
            for (NSString *statTypeKey in stats.allKeys) {
                StatType statType = [EventTeamStat statTypeForDictionaryKey:statTypeKey];
                if (statType == StatTypeUnknown) {
                    continue;
                }
                [EventTeamStat insertEventTeamStats:stats[statTypeKey] ofType:statType forEvent:event inManagedObjectContext:backgroundContext];
            }
            
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventTeamStat *teamStat = (EventTeamStat *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = [teamStat statTypeString];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%.2f", teamStat.score.doubleValue];
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No stats for this event"];
}

@end
