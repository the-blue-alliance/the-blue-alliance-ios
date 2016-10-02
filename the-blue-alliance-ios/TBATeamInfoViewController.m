//
//  TBATeamInfoViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamInfoViewController.h"
#import "TBAInfoTableViewCell.h"
#import "Team.h"

static NSString *const BasicCellReuseIdentifier     = @"BasicCell";

@interface TBATeamInfoViewController ()

@property (nonatomic, assign) BOOL sponsorsExpanded;

@end

@implementation TBATeamInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionFooterHeight = 0.0f;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBAInfoTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:InfoCellReuseIdentifier];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.team) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
    
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshTeam];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return !self.team.name;
}

- (void)refreshTeam {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchTeamForTeamKey:self.team.key withCompletionBlock:^(TBATeam *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Team insertTeamWithModelTeam:team inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = 2;
    } else if (section == 1) {
        rows = self.team.website != nil ? 4 : 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TBAInfoTableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];
            localCell.team = self.team;
            
            localCell.accessoryType = UITableViewCellAccessoryNone;
            localCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = localCell;
        } else if (indexPath.row == 1) {
            UITableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:BasicCellReuseIdentifier forIndexPath:indexPath];
            
            localCell.textLabel.text = self.team.name;
            localCell.textLabel.textColor = [UIColor darkGrayColor];
            if (self.sponsorsExpanded) {
                localCell.textLabel.numberOfLines = 0;
                localCell.accessoryType = UITableViewCellAccessoryNone;
                localCell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                localCell.textLabel.numberOfLines = 3;
                localCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                localCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }

            cell = localCell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:BasicCellReuseIdentifier forIndexPath:indexPath];
        
        NSInteger row = indexPath.row;
        if (!self.team.website) {
            row++;
        }
        switch (row) {
            case 0:
                localCell.textLabel.text = @"View team's website";
                break;
            case 1:
                localCell.textLabel.text = [NSString stringWithFormat:@"View #frc%@ on Twitter", self.team.teamNumber];
                break;
            case 2:
                localCell.textLabel.text = [NSString stringWithFormat:@"View frc%@ on YouTube", self.team.teamNumber];
                break;
            case 3:
                localCell.textLabel.text = @"View photos on Chief Delphi";
                break;
            default:
                break;
        }
        localCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        localCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        cell = localCell;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1 && !self.sponsorsExpanded) {
        self.sponsorsExpanded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    } else if (indexPath.section == 1) {
        NSInteger row = indexPath.row;
        if (!self.team.website) {
            row++;
        }
        NSString *url;
        switch (row) {
            case 0:
                url = self.team.website;
                break;
            case 1:
                url = [NSString stringWithFormat:@"https://twitter.com/search?q=%%23%@", self.team.key];
                break;
            case 2:
                url = [NSString stringWithFormat:@"https://www.youtube.com/results?search_query=%@", self.team.key];
                break;
            case 3:
                url = [NSString stringWithFormat:@"http://www.chiefdelphi.com/media/photos/tags/%@", self.team.key];
                break;
            default:
                break;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

@end
