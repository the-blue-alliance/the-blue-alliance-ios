//
//  TBAEventStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAEventStatsViewController.h"
#import "TBASummaryTableViewCell.h"
#import "EventTeamStat.h"
#import "Event.h"
#import "OrderedDictionary.h"

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBAEventStatsViewController () <TBATableViewControllerDelegate>

/* THIS is a mess. But here's how I'm handling this.
 * Keys for the dictionary should correspond to section header titles
 * Each section for for the table view is going to have an dictionary associated with it
 * This dictionary will have keys associated with the data they need, and a value that is the title for the cell
 */
@property (nonatomic, strong) OrderedDictionary *eventStats;

@end

@implementation TBAEventStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.event) {
            [strongSelf setupEventStatsDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
    
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshEventStats];
    };
    
    self.tbaDelegate = self;
    self.cellIdentifier = SummaryCellReuseIdentifier;
    
    [self setupEventStatsDictionary];
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    BOOL shouldRefresh = NO;
    // Only show event stats for 2016 and onward
    if (self.event.year.integerValue >= 2016) {
        shouldRefresh = (self.event.stats == nil);
    }
    return shouldRefresh;
}

- (void)refreshEventStats {
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

#pragma mark - Private Methods

- (void)setupEventStatsDictionary {
    MutableOrderedDictionary *eventStats = [[MutableOrderedDictionary alloc] init];

    if (self.event.year.integerValue == 2016) {
        // Stronghold
        NSArray *matchStatsKeys = @[@"high_score", @"average_low_goals", @"average_high_goals", @"average_score", @"average_win_score", @"average_win_margin", @"average_auto_score", @"average_crossing_score", @"average_boulder_score", @"average_tower_score", @"average_foul_score"];
        NSArray *matchStatsTitles = @[@"High Score", @"Average Low Goals", @"Average High Goals", @"Average Match Score", @"Average Winning Score", @"Average Win Margin", @"Average Auto Score", @"Teleop Crossing", @"Average Teleop Boulder Score", @"Average Teleop Tower Score", @"Average Foul Score"];
        OrderedDictionary *matchStats = [[OrderedDictionary alloc] initWithObjects:matchStatsTitles forKeys:matchStatsKeys];
        eventStats[@"Match Stats"] = matchStats;
        
        NSArray *defenseStatsKeys = @[@"LowBar", @"A_ChevalDeFrise", @"A_Portcullis", @"B_Ramparts", @"C_SallyPort", @"B_Moat", @"C_Drawbridge", @"D_RoughTerrain", @"D_RockWall", @"breaches"];
        NSArray *defenseStatsTitles = @[@"Low Bar", @"Cheval De Frise", @"Portcullis", @"Ramparts", @"SallyPort", @"Moat", @"Drawbridge", @"Rough Terrain", @"Rock Wall", @"Total Breaches"];
        OrderedDictionary *defenseStats = [[OrderedDictionary alloc] initWithObjects:defenseStatsTitles forKeys:defenseStatsKeys];
        eventStats[@"Defense Stats (# damaged / # opportunities)"] = defenseStats;
        
        NSArray *towerStatsKeys = @[@"challenges", @"scales", @"captures"];
        NSArray *towerStatsTitles = @[@"Challenges", @"Scales", @"Captures"];
        OrderedDictionary *towerStats = [[OrderedDictionary alloc] initWithObjects:towerStatsTitles forKeys:towerStatsKeys];
        eventStats[@"Tower Stats (# successful / # opportunities)"] = towerStats;
        
        self.eventStats = eventStats;
    }
}

#pragma mark - Table View Data Source

// Since we're overriding table view data source methods, it's our responsibility to handle showing no data states

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if (self.event.stats && self.eventStats && self.eventStats.allKeys.count != 0) {
        sections = self.eventStats.allKeys.count;
    } else if (self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;

    NSDictionary *keysDict = self.eventStats[self.eventStats.allKeys[section]];
    if (keysDict && keysDict.allKeys.count != 0) {
        rows = keysDict.allKeys.count;
    } else if (self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    
    return rows;
}

#pragma mark - Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.eventStats.allKeys[section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.font = [UIFont systemFontOfSize:16.0f];
        header.backgroundView.backgroundColor = [UIColor primaryDarkBlue];
        header.textLabel.textColor = [UIColor whiteColor];

        // Setting the textLabel title here to override a grouped table
        // view's default behavior of capitalizing the header title's
        header.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    }
}

#pragma mark - TBATableViewControllerDelegate

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No stats for this event"];
}

- (void)configureCell:(TBASummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.event.year.integerValue == 2016) {
        // Stronghold
        if (indexPath.section == 0 && indexPath.row > 0) {
            // Grab the key for the dictionary we need (Match Stats, Defense Stats, Tower Stats)
            NSString *dictKey = self.eventStats.allKeys[indexPath.section];
            NSDictionary<NSString *, NSString *> *dataDict = self.eventStats[dictKey];
            
            // Grab the key for the data we need (high_score, A_ChevalDeFrise, etc.)
            NSString *dataKey = dataDict.allKeys[indexPath.row];
            NSString *dataTitle = dataDict[dataKey];
            
            NSNumber *qualData = self.event.stats[@"qual"][dataKey];
            NSNumber *playoffData = self.event.stats[@"playoff"][dataKey];

            NSString *qualsString = [NSString stringWithFormat:@"Quals: %.2f", qualData.doubleValue];
            NSString *playoffsString = [NSString stringWithFormat:@"Playoffs: %.2f", playoffData.doubleValue];

            cell.titleLabel.text = dataTitle;
            
            // Remove Qual info for Einstein
            NSString *subtitleString;
            if (self.event.eventType.integerValue == TBAEventTypeCMPFinals) {
                subtitleString = playoffsString;
            } else {
                subtitleString = [NSString stringWithFormat:@"%@\n%@", qualsString, playoffsString];
            }
            cell.subtitleLabel.text = subtitleString;
        } else {
            // Grab the key for the dictionary we need (Match Stats, Defense Stats, Tower Stats)
            NSString *dictKey = self.eventStats.allKeys[indexPath.section];
            NSDictionary<NSString *, NSString *> *dataDict = self.eventStats[dictKey];
            
            // Grab the key for the data we need (high_score, A_ChevalDeFrise, etc.)
            NSString *dataKey = dataDict.allKeys[indexPath.row];
            NSString *dataTitle = dataDict[dataKey];
            
            NSArray<NSNumber *> *qualData = self.event.stats[@"qual"][dataKey];
            NSArray<NSNumber *> *playoffData = self.event.stats[@"playoff"][dataKey];
            
            NSString *subtitleString;
            if (indexPath.section == 0 && indexPath.row == 0) {
                // High Score
                NSString *highScoreStringFormat = @"%@ in %@";
                NSString *qualsString = [NSString stringWithFormat:highScoreStringFormat, qualData[0], qualData[2]];
                NSString *playoffsString = [NSString stringWithFormat:highScoreStringFormat, playoffData[0], playoffData[2]];
                
                // Remove Qual info for Einstein
                if (self.event.eventType.integerValue == TBAEventTypeCMPFinals) {
                    subtitleString = playoffsString;
                } else {
                    subtitleString = [NSString stringWithFormat:@"%@\n%@", qualsString, playoffsString];
                }
            } else {
                // All the defense and tower stats
                NSString *dataStringFormat = @"%@: %@ / %@ = %.2f%%";
                NSString *qualsString = [NSString stringWithFormat:dataStringFormat, @"Quals", qualData[0], qualData[1], qualData[2].doubleValue];
                NSString *playoffsString = [NSString stringWithFormat:dataStringFormat, @"Playoffs", playoffData[0], playoffData[1], playoffData[2].doubleValue];

                // Remove Qual info for Einstein
                if (self.event.eventType.integerValue == TBAEventTypeCMPFinals) {
                    subtitleString = playoffsString;
                } else {
                    subtitleString = [NSString stringWithFormat:@"%@\n%@", qualsString, playoffsString];
                }
            }
            
            cell.titleLabel.text = dataTitle;
            cell.subtitleLabel.text = subtitleString;
        }
    }
}

@end
