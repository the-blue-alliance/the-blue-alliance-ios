//
//  DistrictRankingsTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictRankingsViewController.h"
#import "DistrictRankingTableViewCell.h"
#import "DistrictRanking.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "District+Fetch.h"


static NSString *const DistrictRankCellReuseIdentifier  = @"DistrictRankCell";


@interface DistrictRankingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *rankings;

@end

@implementation DistrictRankingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchDistrictRankings];
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Data Methods

- (void)fetchDistrictRankings {
    self.rankings = nil;
    
    __weak typeof(self) weakSelf = self;
    [District fetchDistrictRankingsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *rankings, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch district rankings locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!rankings || [rankings count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.rankings = rankings;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rankings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DistrictRankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DistrictRankCellReuseIdentifier forIndexPath:indexPath];
    
    DistrictRanking *districtRanking = [self.rankings objectAtIndex:indexPath.row];
    
    cell.teamNameLabel.text = [districtRanking.team nickname];
    cell.teamNumberLabel.text = [NSString stringWithFormat:@"%lld", districtRanking.team.teamNumber];
    cell.rankLabel.text = [NSString stringWithFormat:@"Rank %d", districtRanking.rank];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%d Points", districtRanking.pointTotal];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
