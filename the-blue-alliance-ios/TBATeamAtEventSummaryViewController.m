//
//  TBATeamSummaryViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/25/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamAtEventSummaryViewController.h"
#import "TBASummaryTableViewCell.h"
#import "EventAlliance.h"
#import "EventRanking.h"
#import "Event.h"
#import "Team.h"
#import "NSNumber+Additions.h"

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBATeamAtEventSummaryViewController ()

@property (nonatomic, strong) EventAlliance *eventAlliance;

@end

@implementation TBATeamAtEventSummaryViewController
@synthesize eventRanking = _eventRanking;

#pragma mark - Properities

- (void)setEventAlliance:(EventAlliance *)eventAlliance {
    _eventAlliance = eventAlliance;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setEventRanking:(EventRanking *)eventRanking {
    _eventRanking = eventRanking;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (EventRanking *)eventRanking {
    if (_eventRanking) {
        return _eventRanking;
    }

    return [EventRanking fetchInContext:self.persistenceController.managedObjectContext configure:^(NSFetchRequest * _Nonnull fetch) {
        fetch.predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@", self.event, self.team];
        fetch.returnsObjectsAsFaults = NO;
        fetch.fetchLimit = 1;
    }].firstObject;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.eventRanking || changedObject == strongSelf.event) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        } else if (changedObject == self.event) {
            [strongSelf setupEventAlliance];
        }
    }];
    
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf refreshEventRanking];
        [strongSelf refreshEvent];
    };
    
    self.tbaDelegate = self;
    self.cellIdentifier = SummaryCellReuseIdentifier;

    [self setupEventAlliance];
}

#pragma mark - Private Methods

- (void)setupEventAlliance {
    for (EventAlliance *alliance in self.event.alliances) {
        if ([alliance.picks containsObject:self.team]) {
            self.eventAlliance = alliance;
            break;
        }
    }
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.eventRanking == nil;
}

- (void)refreshEventRanking {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchRankingsForEventKey:self.event.key withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload event rankings"];
        }
        
        Event *event = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.event.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            NSArray *eventRankings = [EventRanking insertEventRankingsWithEventRankings:rankings forEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            for (EventRanking *ranking in eventRankings) {
                if (ranking.team == strongSelf.team) {
                    strongSelf.eventRanking = ranking;
                    break;
                }
            }
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Event insertEventWithModelEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
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
    NSInteger rows = 1;
    if (self.eventRanking) {
        rows = 3;
    }
    return rows;
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.eventRanking) {
        cell.titleLabel.text = @"Rank";
        cell.subtitleLabel.text = [self.eventRanking.rank stringWithSuffix];
    } else if ((indexPath.row == 1 && self.eventRanking) || (indexPath.row == 0 && !self.eventRanking)) {
        cell.titleLabel.text = @"Alliance";
        if (self.eventAlliance) {
            NSNumber *pickOrder = @([self.eventAlliance.picks indexOfObject:self.team]);
            if (pickOrder.integerValue == 0) {
                cell.subtitleLabel.text = [NSString stringWithFormat:@"Captain of the %@ alliance", [self.eventAlliance.allianceNumber stringWithSuffix]];
            } else {
                cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ pick on the %@ alliance", [pickOrder stringWithSuffix], [self.eventAlliance.allianceNumber stringWithSuffix]];
            }
        } else {
            cell.subtitleLabel.text = @"Not picked for an alliance";
        }
    } else {
        NSMutableArray *breakdownArray = [[NSMutableArray alloc] init];
        for (NSString *key in self.eventRanking.info) {
            [breakdownArray addObject:[NSString stringWithFormat:@"%@: %@", key, self.eventRanking.info[key]]];
        }
        
        cell.titleLabel.text = @"Ranking Breakdown";
        cell.subtitleLabel.text = [breakdownArray componentsJoinedByString:@", "];
    }
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No summary for team at event"];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
