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
#import "Event+Fetch.h"
#import "Media.h"

static NSString *const InfoCellReuseIdentifier      = @"InfoCell";

static NSString *const EventOptionAlliances         = @"Alliances";
static NSString *const EventOptionDistrictPoints    = @"District Points";
static NSString *const EventOptionStats             = @"Stats";
static NSString *const EventOptionAwards            = @"Awards";

@interface TBAInfoViewController ()

@property (nonatomic, strong) NSArray *infoArray;

@end

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForChangeNotifications];
    [self setupInfoArray];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.team) {
            [strongSelf refreshTeam];
        } else if (strongSelf.event) {
            [strongSelf refreshEvent];
        }
    };
}

#pragma mark - Private Methods

- (void)registerForChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            if (obj == self.event || obj == self.team) {
                [self setupInfoArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)setupInfoArray {
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    if (self.team) {
        if (self.team.location) {
            [dataArr addObject:self.team.location];
        }
        if (self.team.name) {
            [dataArr addObject:self.team.name];
        }
        if (self.team.motto) {
            [dataArr addObject:self.team.motto];
        }
    } else if (self.event) {
        if ([self.event dateString]) {
            [dataArr addObject:[self.event dateString]];
        }
        if (self.event.location) {
            [dataArr addObject:self.event.location];
        }
    }
    self.infoArray = dataArr;
}

#pragma mark - Data Methods

- (void)refreshTeam {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchTeamForTeamKey:self.team.key withCompletionBlock:^(TBATeam *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        } else {
            [strongSelf.persistenceController performChanges:^{
                [Team insertTeamWithModelTeam:team inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            }];
        }
    }];
    [self addRequestIdentifier:request];
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        } else {
            [strongSelf.persistenceController performChanges:^{
                [Event insertEventWithModelEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            }];
        }
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
        rows = self.infoArray.count;
    } else {
        if (self.event) {
            if (section == 1) {
                rows = self.event.isDistrict ? 4 : 3;
            } else {
                rows = self.event.website != nil ? 4 : 3;
            }
        } else if (self.team) {
            rows = self.team.website != nil ? 4 : 3;
        }
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];

    if (indexPath.section == 0) {
        NSString *text = [self.infoArray objectAtIndex:indexPath.row];
        if (self.team) {
            if ([text isEqualToString:self.team.location]) {
                cell.textLabel.text = [NSString stringWithFormat:@"from %@", text];
            } else if ([text isEqualToString:self.team.name]) {
                cell.textLabel.text = text;
                cell.textLabel.numberOfLines = 0;
            } else if ([text isEqualToString:self.team.motto]) {
                cell.textLabel.text = text;
                cell.textLabel.numberOfLines = 0;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (self.event) {
            cell.textLabel.text = text;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        NSInteger row = indexPath.row;
        if (self.event) {
            if (indexPath.section == 1) {
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
            } else if (indexPath.section == 2) {
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
        } else if (self.team) {
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
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleName;
    if (section == 0) {
        titleName = [self titleString];
    } else if ((self.event && section == 2) || self.team) {
        titleName = @"Social media";
    }
    return titleName;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.font = [UIFont systemFontOfSize:16.0f];

        // Setting the textLabel title here to override a grouped table
        // view's default behavior of capitalizing the header title's
        header.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    }
}

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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - Private Methods

- (NSString *)titleString {
    NSString *titleString;
    if (self.team) {
        if (self.team.name) {
            titleString = [self.team nickname];
        } else {
            titleString = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
        }
    } else {
        titleString = self.event.name;
    }
    return titleString;
}

@end
