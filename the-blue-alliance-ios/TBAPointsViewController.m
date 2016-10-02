//
//  TBAPointsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAPointsViewController.h"
#import "TBAPointsTableViewCell.h"
#import "District.h"
#import "DistrictRanking.h"
#import "Event.h"
#import "EventPoints.h"
#import "Team.h"

@implementation TBAPointsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistenceController) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest;
    NSString *cacheName;
    if (self.event) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventPoints"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"total" ascending:NO]];
        
        cacheName = [NSString stringWithFormat:@"%@_points", self.event.key];
    } else if (self.district) {
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DistrictRanking"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"district == %@", self.district];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES]];
        
        cacheName = [NSString stringWithFormat:@"%@_rankings", self.district.key];
    }

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
    self.cellIdentifier = PointsCellReuseIdentifier;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBAPointsTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.district) {
            [strongSelf refreshDistrictPoints];
        } else {
            [strongSelf refreshEventPoints];
        }
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshDistrictPoints {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.district.key forYear:self.district.year.integerValue withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload district rankings"];
        }
        
        District *district = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.district.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:district inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

- (void)refreshEventPoints {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchDistrictPointsForEventKey:self.event.key withCompletionBlock:^(NSDictionary *points, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload district points"];
        }
        
        NSDictionary *pointsDict = [points objectForKey:@"points"];
        Event *event = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.event.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            [EventPoints insertEventPointsWithEventPointsDict:pointsDict forEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAPointsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.district) {
        DistrictRanking *ranking = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.districtRanking = ranking;
    } else if (self.event) {
        EventPoints *points = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.eventPoints = points;
        cell.rankLabel.text = [NSString stringWithFormat:@"Rank %ld", (long)(indexPath.row + 1)];
    }
}

- (void)showNoDataView {
    if (self.district) {
        [self showNoDataViewWithText:@"No points for this district"];
    } else {
        [self showNoDataViewWithText:@"No points for this event"];
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.pointsSelected) {
        id points = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.pointsSelected(points);
    }
}

@end
