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

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBADistrictRankingBreakdownViewController () <TBATableViewControllerDelegate>

@property (nonatomic, strong) NSArray *sortedEventPoints;

@end

@implementation TBADistrictRankingBreakdownViewController

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

- (void)refreshDistrictRankings {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForDistrictShort:self.districtRanking.district.key forYear:self.districtRanking.district.year.integerValue withCompletionBlock:^(NSArray *rankings, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload event points"];
        } else {
            District *district = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.districtRanking.district.objectID];
            
            [strongSelf.persistenceController performChanges:^{
                [DistrictRanking insertDistrictRankingsWithDistrictRankings:rankings forDistrict:district inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            }];
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.districtRanking.eventPoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventPoints *eventPoints = self.sortedEventPoints[indexPath.section];

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
    EventPoints *eventPoints = self.sortedEventPoints[section];
    
    NSString *title;
    if (eventPoints.districtCMP) {
        title = eventPoints.event.name;
    } else {
        title = [NSString stringWithFormat:@"%@ District - %@", [self.districtRanking.district.key uppercaseString], eventPoints.event.name];
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
