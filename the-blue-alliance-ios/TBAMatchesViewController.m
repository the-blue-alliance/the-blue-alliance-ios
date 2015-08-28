//
//  TBAMatchesViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMatchesViewController.h"
#import "TBAMatchTableViewCell.h"

static NSString *const MatchCellReuseIdentifier = @"MatchCell";

@implementation TBAMatchesViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if (!self.matches) {
        // TODO: Show no data screen
        count = 0;
    } else {
        count = [self.matches count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAMatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MatchCellReuseIdentifier forIndexPath:indexPath];
    
    Match *match = [self.matches objectAtIndex:indexPath.row];
    cell.match = match;
    
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
    
    if (self.matchSelected) {
        Match *match = [self.matches objectAtIndex:indexPath.row];
        self.matchSelected(match);
    }
}

@end
