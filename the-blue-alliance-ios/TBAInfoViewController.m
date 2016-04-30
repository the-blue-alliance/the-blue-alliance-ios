//
//  TBAInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAInfoViewController.h"
#import "OpenInGoogleMapsController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "Media.h"
#import <EventKitUI/EventKitUI.h>

static NSString *const InfoCellReuseIdentifier      = @"InfoCell";

static NSString *const EventOptionAlliances         = @"Alliances";
static NSString *const EventOptionDistrictPoints    = @"District Points";
static NSString *const EventOptionStats             = @"Stats";
static NSString *const EventOptionAwards            = @"Awards";

@interface TBAInfoViewController () <EKEventViewDelegate, EKEventEditViewDelegate>

@property (nonatomic, strong) NSArray *infoArray;

@end

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.event || changedObject == strongSelf.team) {
            [strongSelf setupInfoArray];
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
    
    [self setupInfoArray];
}

#pragma mark - Private Methods

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
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                if ([text isEqualToString:self.team.name]) {
                    cell.textLabel.text = text;
                    cell.textLabel.numberOfLines = 0;
                } else if ([text isEqualToString:self.team.motto]) {
                    cell.textLabel.text = text;
                    cell.textLabel.numberOfLines = 0;
                }
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        } else if (self.event) {
            cell.textLabel.text = text;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
    if (indexPath.section == 0) {
        NSString *text = [self.infoArray objectAtIndex:indexPath.row];
        
        GoogleMapDefinition *definition = [[GoogleMapDefinition alloc] init];
        if (self.team && [text isEqualToString:self.team.location]) {
            definition.queryString = self.team.location;
            [[OpenInGoogleMapsController sharedInstance] openMap:definition];
        } else if (self.event) {
            if ([text isEqualToString:self.event.location]) {
                definition.queryString = self.event.location;
                [[OpenInGoogleMapsController sharedInstance] openMap:definition];
            } else {
                [self createEventCalendarEvent];
            }
        }
    }
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

- (void)createEventCalendarEvent {
    EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createEventAndPresentViewController:store];
            });
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to access Calendar" message:@"Permission was not granted for Calendar" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            [alert addAction:settingsAction];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

- (void)createEventAndPresentViewController:(EKEventStore *)store {
    EKEvent *event = [self findCalendarEventInEventStore:store];

    if (event) {
        EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:eventViewController];

        eventViewController.event = event;
        eventViewController.allowsEditing = YES;
        eventViewController.delegate = self;
        
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        event = [self createEvent:store];
        
        EKEventEditViewController *editEventViewController = [[EKEventEditViewController alloc] init];
        editEventViewController.event = event;
        editEventViewController.eventStore = store;
        editEventViewController.editViewDelegate = self;
        
        [self presentViewController:editEventViewController animated:YES completion:nil];
    }
}

- (EKEvent *)createEvent:(EKEventStore *)store {
    EKEvent *event = [EKEvent eventWithEventStore:store];
    event.title = [NSString stringWithFormat:@"%@ Event", [self.event friendlyNameWithYear:YES]];
    event.allDay = YES;
    event.location = self.event.location;
    event.calendar = [store defaultCalendarForNewEvents];
    event.startDate = self.event.startDate;
    event.endDate = self.event.endDate;

    return event;
}

- (EKEvent *)findCalendarEventInEventStore:(EKEventStore *)store {
    // Find calendar event with start/end date of our event
    NSPredicate *predicate = [store predicateForEventsWithStartDate:self.event.startDate
                                                            endDate:self.event.endDate
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [store eventsMatchingPredicate:predicate];
    
    for (EKEvent *event in events) {
        if ([[NSString stringWithFormat:@"%@ Event", [self.event friendlyNameWithYear:YES]] isEqualToString:event.title]) {
            return event;
        }
    }
    
    return nil;
}

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
