//
//  TBARankingsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARankingsViewController.h"
#import "TBADistrictRankingTableViewCell.h"

static NSString *const DistrictRankCellReuseIdentifier  = @"DistrictRankCell";

@implementation TBARankingsViewController

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if (!self.rankings) {
        // TODO: Show no data screen
        count = 0;
    } else {
        count = [self.rankings count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (self.district) {
        TBADistrictRankingTableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:DistrictRankCellReuseIdentifier
                                                                                     forIndexPath:indexPath];

        DistrictRanking *ranking = [self.rankings objectAtIndex:indexPath.row];
        localCell.districtRanking = ranking;
        
        cell = localCell;
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.rankingSelected) {
        id ranking = [self.rankings objectAtIndex:indexPath.row];
        self.rankingSelected(ranking);
    }
}

@end
