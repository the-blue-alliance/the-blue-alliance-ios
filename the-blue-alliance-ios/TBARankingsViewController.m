//
//  TBARankingsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARankingsViewController.h"
#import "TBARankingTableViewCell.h"

static NSString *const RankCellReuseIdentifier  = @"RankCell";

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
    TBARankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RankCellReuseIdentifier forIndexPath:indexPath];
    
    if (self.district) {
        DistrictRanking *ranking = [self.rankings objectAtIndex:indexPath.row];
        cell.districtRanking = ranking;
    } else if (self.event) {
        EventRanking *ranking = [self.rankings objectAtIndex:indexPath.row];
        cell.eventRanking = ranking;
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.rankingSelected) {
        id ranking = [self.rankings objectAtIndex:indexPath.row];
        self.rankingSelected(ranking);
    }
}

@end
