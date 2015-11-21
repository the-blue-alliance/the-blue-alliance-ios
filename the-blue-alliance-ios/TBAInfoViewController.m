//
//  TBAInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAInfoViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event.h"
#import "Media.h"

static NSString *const InfoCellReuseIdentifier = @"InfoCell";

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf refreshTeam];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Data Methods

- (void)fetchTeamAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [Team fetchTeamForKey:self.team.key fromContext:self.persistenceController.managedObjectContext checkUpstream:NO withCompletionBlock:^(Team *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to fetch team info locally"];
            });
            return;
        }
        
        if (!team) {
            if (refresh) {
                [self refresh];
            }
        } else {
            strongSelf.team = team;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}

- (void)refreshTeam {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchTeamForTeamKey:self.team.key withCompletionBlock:^(TBATeam *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Team insertTeamWithModelTeam:team inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchTeamAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.team) {
        return 3;
    } else if (self.event) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];

#warning this needs to change based on the data we do/don't have
    if (self.team.location && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"from %@", self.team.location];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.team.name && indexPath.row == 1) {
        cell.textLabel.text = self.team.name;
        cell.textLabel.numberOfLines = 0;
    } else if (self.event.dateString && indexPath.row == 0) {
        cell.textLabel.text = self.event.dateString;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.team.website && indexPath.row == 2) {
        cell.textLabel.text = self.team.website;

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (self.event.location && indexPath.row == 1) {
        cell.textLabel.text = self.event.location;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleString];
}

/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.textLabel.text = [self titleString];
        tableViewHeaderFooterView.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        tableViewHeaderFooterView.textLabel.textColor = [UIColor blackColor];
    }
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Methods

- (NSString *)titleString {
    if (self.team) {
        return [self.team nickname];
    } else {
        return self.event.name;
    }
}

@end
