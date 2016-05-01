//
//  TBATeamStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamStatsViewController.h"
#import "TBATeamStatsTableViewCell.h"
#import "EventTeamStat.h"
#import "Event.h"

static NSString *const TeamStatsCellReuseIdentifier = @"TeamStatsCell";

@interface TBATeamStatsViewController () <TBATableViewControllerDelegate>

@end

@implementation TBATeamStatsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (!self.persistenceController) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventTeamStat"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@ AND statType == %@", self.event, @(StatTypeOPR)];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
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
    self.cellIdentifier = TeamStatsCellReuseIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshTeamStats];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}


- (void)refreshTeamStats {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchStatsForEventKey:self.event.key withCompletionBlock:^(NSDictionary *stats, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team stats"];
        }
        
        Event *event = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.event.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            for (NSString *statTypeKey in stats.allKeys) {
                if ([statTypeKey  isEqualToString:@"year_specific"]) {
                    event.stats = stats[statTypeKey];
                } else {
                    StatType statType = [EventTeamStat statTypeForDictionaryKey:statTypeKey];
                    if (statType == StatTypeUnknown) {
                        continue;
                    }
                    [EventTeamStat insertEventTeamStats:stats[statTypeKey] ofType:statType forEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
                }
            }
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBATeamStatsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventTeamStat *stat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *teamStats = [EventTeamStat fetchInContext:self.persistenceController.managedObjectContext configure:^(NSFetchRequest * _Nonnull fetchRequest) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@", self.event, stat.team];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"statType" ascending:YES]];
    }];
    cell.teamStats = teamStats;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No team stats"];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.teamSelected) {
        EventTeamStat *stat = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.teamSelected(stat.team);
    }
}

@end
