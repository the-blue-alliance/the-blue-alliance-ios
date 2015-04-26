//
//  TeamsCollectionViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsCollectionViewCell.h"
#import "TeamTableViewCell.h"
#import "Team.h"


static NSString *const TeamCellReuseIdentifier = @"Team Cell";


@implementation TeamsCollectionViewCell

#pragma mark - Initilization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.teams) {
        return 0;
    }
    return [self.teams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
    
    Team *team = [self.teams objectAtIndex:indexPath.row];
    
    cell.numberLabel.text = [team.team_number stringValue];
    cell.nameLabel.text = team.nickname;
    cell.locationLabel.text = team.location;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
