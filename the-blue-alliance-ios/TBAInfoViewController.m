//
//  TBAInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAInfoViewController.h"
#import "TBAInfoTableViewCell.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "Media.h"

static NSString *const InfoCellReuseIdentifier      = @"InfoCell";
static NSString *const BasicCellReuseIdentifier     = @"BasicCell";

static NSString *const EventOptionAlliances         = @"Alliances";
static NSString *const EventOptionDistrictPoints    = @"District Points";
static NSString *const EventOptionStats             = @"Stats";
static NSString *const EventOptionAwards            = @"Awards";

@interface TBAInfoViewController ()

@end

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionFooterHeight = 0.0f;
    
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
        
        if (strongSelf.team) {
            [strongSelf refreshTeam];
        } else if (strongSelf.event) {
            [strongSelf refreshEvent];
        }
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return ((self.team && !self.team.name) || (self.event && !self.event.name));
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
    NSInteger sections = 0;
    if (self.event) {
        sections = 3;
    } else if (self.team) {
        sections = 2;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else if (self.event) {
        if (section == 1) {
            rows = self.event.isDistrict ? 4 : 3;
        } else if (section == 2) {
            rows = self.event.website != nil ? 4 : 3;
        }
    } else if (self.team && section == 1) {
        rows = self.team.website != nil ? 4 : 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TBAInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];
        if (self.event) {
            cell.event = self.event;
        } else if (self.team) {
            cell.team = self.team;
        }
        return cell;
    } else if (self.event) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellReuseIdentifier forIndexPath:indexPath];

        if (indexPath.section == 1) {
            NSInteger row = indexPath.row;
            if (indexPath.row >= 1 && ![self.event isDistrict]) {
                row++;
            }
            switch (row) {
                case 0:
                    cell.textLabel.text = EventOptionAlliances;
                    break;
                case 1:
                    cell.textLabel.text = EventOptionDistrictPoints;
                    break;
                case 2:
                    cell.textLabel.text = EventOptionStats;
                    break;
                case 3:
                    cell.textLabel.text = EventOptionAwards;
                    break;
                    
                default:
                    break;
            }
        } else {
            NSInteger row = indexPath.row;
            if (!self.event.website) {
                row++;
            }
            switch (row) {
                case 0:
                    cell.textLabel.text = @"View event's website";
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"View #%@ on Twitter", self.event.key];
                    break;
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"View %@ on YouTube", self.event.key];
                    break;
                case 3:
                    cell.textLabel.text = @"View photos on Chief Delphi";
                    break;
                    
                default:
                    break;
            }
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        return cell;
    } else if (self.team) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellReuseIdentifier forIndexPath:indexPath];

        NSInteger row = indexPath.row;
        if (!self.team.website) {
            row++;
        }
        switch (row) {
            case 0:
                cell.textLabel.text = @"View team's website";
                break;
            case 1:
                cell.textLabel.text = [NSString stringWithFormat:@"View #frc%@ on Twitter", self.team.teamNumber];
                break;
            case 2:
                cell.textLabel.text = [NSString stringWithFormat:@"View frc%@ on YouTube", self.team.teamNumber];
                break;
            case 3:
                cell.textLabel.text = @"View photos on Chief Delphi";
                break;
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        return cell;
    }
    return nil;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = indexPath.row;
    if (self.event) {
        if (indexPath.section == 1) {
            if (indexPath.row >= 1 && ![self.event isDistrict]) {
                row++;
            }
            switch (row) {
                case 0:
                    if (self.showAlliances) {
                        self.showAlliances();
                    }
                    break;
                case 1:
                    if (self.showDistrictPoints) {
                        self.showDistrictPoints();
                    }
                    break;
                case 2:
                    if (self.showStats) {
                        self.showStats();
                    }
                    break;
                case 3:
                    if (self.showAwards) {
                        self.showAwards();
                    }
                    break;
                    
                default:
                    break;
            }
        } else if (indexPath.section == 2) {
            if (!self.event.website) {
                row++;
            }
            NSString *url;
            switch (row) {
                case 0:
                    url = self.event.website;
                    break;
                case 1:
                    url = [NSString stringWithFormat:@"https://twitter.com/search?q=%%23%@", self.event.key];
                    break;
                case 2:
                    url = [NSString stringWithFormat:@"https://www.youtube.com/results?search_query=%@", self.event.key];
                    break;
                case 3:
                    url = [NSString stringWithFormat:@"http://www.chiefdelphi.com/media/photos/tags/%@", self.event.key];
                    break;
                default:
                    break;
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                });
            }
        }
    } else if (self.team && indexPath.section == 1) {
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
