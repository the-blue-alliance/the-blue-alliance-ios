//
//  TBATeamAtEventStatsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamAtEventStatsViewController.h"
#import "TBASummaryTableViewCell.h"

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBATeamAtEventStatsViewController () <TBATableViewControllerDelegate>

@end

@implementation TBATeamAtEventStatsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.event || changedObject == strongSelf.team) {
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
}

- (void)refreshEventStats {
    // Something in here
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

@end
