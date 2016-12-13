//
//  TBAEventInfoViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAEventInfoViewController.h"
#import "TBAInfoTableViewCell.h"
#import "Event.h"

static NSString *const BasicCellReuseIdentifier     = @"BasicCell";

static NSString *const EventOptionAlliances         = @"Alliances";
static NSString *const EventOptionDistrictPoints    = @"District Points";
static NSString *const EventOptionStats             = @"Stats";
static NSString *const EventOptionAwards            = @"Awards";

@implementation TBAEventInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionFooterHeight = 0.0f;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TBAInfoTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:InfoCellReuseIdentifier];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.event) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
    
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshEvent];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return !self.event.name;
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext * _Nonnull backgroundContext) {
            [Event insertEventWithModelEvent:event inManagedObjectContext:backgroundContext];
            [backgroundContext save:nil];
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        rows = self.event.isDistrict ? 4 : 3;
    } else if (section == 2) {
        rows = self.event.website != nil ? 4 : 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        TBAInfoTableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];
        localCell.event = self.event;

        localCell.accessoryType = UITableViewCellAccessoryNone;
        localCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = localCell;
    } else {
        UITableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:BasicCellReuseIdentifier forIndexPath:indexPath];
        NSInteger row = indexPath.row;

        if (indexPath.section == 1) {
            if (indexPath.row >= 1 && ![self.event isDistrict]) {
                row++;
            }
            switch (row) {
                case 0:
                    localCell.textLabel.text = EventOptionAlliances;
                    break;
                case 1:
                    localCell.textLabel.text = EventOptionDistrictPoints;
                    break;
                case 2:
                    localCell.textLabel.text = EventOptionStats;
                    break;
                case 3:
                    localCell.textLabel.text = EventOptionAwards;
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
                    localCell.textLabel.text = @"View event's website";
                    break;
                case 1:
                    localCell.textLabel.text = [NSString stringWithFormat:@"View #%@ on Twitter", self.event.key];
                    break;
                case 2:
                    localCell.textLabel.text = [NSString stringWithFormat:@"View %@ on YouTube", self.event.key];
                    break;
                case 3:
                    localCell.textLabel.text = @"View photos on Chief Delphi";
                    break;
                    
                default:
                    break;
            }
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
    
    NSInteger row = indexPath.row;
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
}

@end
