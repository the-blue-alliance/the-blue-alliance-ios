//
//  TBADistrictRankingBreakdownViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBADistrictRankingBreakdownViewController.h"
#import "TBASummaryTableViewCell.h"
#import "DistrictRanking.h"
#import "District.h"
#import "EventPoints.h"
#import "Event.h"

@implementation TBADistrictRankingBreakdownViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistentContainer) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [EventPoints fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"districtRanking == %@", self.districtRanking];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"event.week" ascending:YES]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
                                                                      sectionNameKeyPath:@"event"
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
        [strongSelf refreshDistrictRankings];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshDistrictRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.districtRanking.district.key forYear:self.districtRanking.district.year.integerValue withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
                
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload event points"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            District *district = [backgroundContext objectWithID:strongSelf.districtRanking.district.objectID];
            [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:district inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventPoints *eventPoints = [[[self.fetchedResultsController sections][indexPath.section] objects] firstObject];

    NSString *pointTypeString;
    NSNumber *points;
    if (indexPath.row == 0) {
        pointTypeString = @"Qualification";
        points = eventPoints.qualPoints;
    } else if (indexPath.row == 1) {
        pointTypeString = @"Elimination";
        points = eventPoints.elimPoints;
    } else if (indexPath.row == 2) {
        pointTypeString = @"Alliance";
        points = eventPoints.alliancePoints;
    } else if (indexPath.row == 3) {
        pointTypeString = @"Award";
        points = eventPoints.awardPoints;
    } else if (indexPath.row == 4) {
        pointTypeString = @"Total";
        points = eventPoints.total;
    }
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ Points", pointTypeString];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ Points", points.stringValue];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No breakdown for team at district"];
}

#pragma mark - Table View Delegate

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
    EventPoints *firstEventPoints = [[[self.fetchedResultsController sections][section] objects] firstObject];
    
    NSString *title;
    if (firstEventPoints.districtCMP) {
        title = firstEventPoints.event.name;
    } else {
        title = [NSString stringWithFormat:@"%@ District - %@", [self.districtRanking.district.key uppercaseString], firstEventPoints.event.name];
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
