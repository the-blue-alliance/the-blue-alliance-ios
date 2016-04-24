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
#import "DistrictRanking.h"
#import "Event.h"
#import "EventRanking.h"
#import "EventPoints.h"
#import "Team+Fetch.h"

static NSString *const RankCellReuseIdentifier  = @"RankCell";

@implementation TBARankingsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest;
    NSSortDescriptor *sortDescriptor;
    NSPredicate *predicate;
    NSString *cacheName;
    if (self.event && !self.showPoints) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventRanking"];
        predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
        cacheName = [NSString stringWithFormat:@"%@_rankings", self.event.key];
        [fetchRequest setPredicate:predicate];
        
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    } else if (self.event && self.showPoints) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventPoints"];
        predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
        cacheName = [NSString stringWithFormat:@"%@_points", self.event.key];
        [fetchRequest setPredicate:predicate];
        
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"total" ascending:NO];
    } else if (self.district) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DistrictRanking"];
        predicate = [NSPredicate predicateWithFormat:@"district == %@", self.district];
        cacheName = [NSString stringWithFormat:@"%@_rankings", self.district.key];
        [fetchRequest setPredicate:predicate];

        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
    }
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
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
    self.cellIdentifier = RankCellReuseIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshRankings];
    };
}

#pragma mark - Data Methods

- (void)refreshRankings {
    if (self.district) {
        __weak typeof(self) weakSelf = self;
        __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.year.integerValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeRequestIdentifier:request];
            
            if (error) {
                [strongSelf showErrorAlertWithMessage:@"Unable to reload district rankings"];
            } else {
                [strongSelf.persistenceController performChanges:^{
                    [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:strongSelf.district inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
                }];
            }
        }];
        [self addRequestIdentifier:request];
    } else if (self.event && !self.showPoints) {
        __weak typeof(self) weakSelf = self;
        __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForEventKey:self.event.key withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeRequestIdentifier:request];
            
            if (error) {
                [strongSelf showErrorAlertWithMessage:@"Unable to reload event rankings"];
            } else {
                [strongSelf.persistenceController performChanges:^{
                    [EventRanking insertEventRankingsWithEventRankings:rankings forEvent:strongSelf.event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
                }];
            }
        }];
        [self addRequestIdentifier:request];
    } else if (self.event && self.showPoints) {
        __weak typeof(self) weakSelf = self;
        __block NSUInteger request = [[TBAKit sharedKit] fetchDistrictPointsForEventKey:self.event.key withCompletionBlock:^(NSDictionary *points, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeRequestIdentifier:request];
            
            if (error) {
                [strongSelf showErrorAlertWithMessage:@"Unable to reload district points"];
            } else {
                NSDictionary *pointsDict = points[@"points"];
                for (NSString *teamKey in pointsDict.allKeys) {
                    [Team fetchTeamForKey:teamKey fromContext:strongSelf.persistenceController.backgroundManagedObjectContext checkUpstream:YES withCompletionBlock:^(Team * _Nullable team, NSError * _Nullable error) {
                        if (!error) {
                            [strongSelf.persistenceController performChanges:^{
                                [EventPoints insertEventPointsWithEventPointsDict:pointsDict[teamKey] forEvent:strongSelf.event andTeam:team inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
                            }];
                        }
                    }];
                }
            }
        }];
        [self addRequestIdentifier:request];
    }
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBARankingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.district) {
        DistrictRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.districtRanking = ranking;
    } else if (self.event && !self.showPoints) {
        EventRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.eventRanking = ranking;
    } else if (self.event && self.showPoints) {
        EventPoints *points = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.eventPoints = points;
        cell.rankLabel.text = [NSString stringWithFormat:@"Rank %ld", indexPath.row + 1];
    }
}

- (void)showNoDataView {
    if (self.showPoints) {
        [self showNoDataViewWithText:@"No district points for this event"];
    } else {
        [self showNoDataViewWithText:@"No rankings for this event"];
    }
}

#pragma mark - Table View Delegate

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
