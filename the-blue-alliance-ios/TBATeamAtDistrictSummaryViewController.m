//
//  TBATeamAtDistrictSummaryViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/27/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamAtDistrictSummaryViewController.h"
#import "TBASummaryTableViewCell.h"
#import "District.h"
#import "DistrictRanking.h"
#import "EventPoints.h"
#import "Event.h"
#import "NSNumber+Additions.h"

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBATeamAtDistrictSummaryViewController () <TBATableViewControllerDelegate>

@property (nonatomic, strong) NSArray *sortedEventPoints;

@end

@implementation TBATeamAtDistrictSummaryViewController

#pragma mark - Properities

- (NSArray *)sortedEventPoints {
    if (_sortedEventPoints == nil) {
        NSSortDescriptor *weekSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"event.week" ascending:YES];
        _sortedEventPoints = [self.districtRanking.eventPoints sortedArrayUsingDescriptors:@[weekSortDescriptor]];
    }
    
    return _sortedEventPoints;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf refreshDistrictRankings];
    };
    
    self.tbaDelegate = self;
    self.cellIdentifier = SummaryCellReuseIdentifier;
    
    [self registerForChangeNotifications];
}

#pragma mark - Private Methods

- (void)registerForChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            if (obj == self.districtRanking || obj == self.districtRanking.district) {
                self.sortedEventPoints = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.districtRanking.eventPoints.count == 0;
}

- (void)refreshDistrictRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.districtRanking.district.key forYear:self.districtRanking.district.year.integerValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload district rankings"];
        }
        
        District *district = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.districtRanking.district.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:district inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + self.districtRanking.eventPoints.count;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"District Rank";
        cell.subtitleLabel.text = [self.districtRanking.rank stringWithSuffix];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 1)) {
        cell.titleLabel.text = @"Total Points";
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ Points", self.districtRanking.pointTotal.stringValue];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        EventPoints *eventPoints = self.sortedEventPoints[indexPath.row - 1];
        cell.titleLabel.text = eventPoints.event.shortName;
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ Points", eventPoints.total.stringValue];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No summary for team at district"];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.eventPointsSelected) {
        EventPoints *eventPoints = self.sortedEventPoints[indexPath.row - 1];
        self.eventPointsSelected(eventPoints);
    }
}

@end
