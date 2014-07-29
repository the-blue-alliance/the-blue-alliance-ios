//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event.h"
#import "EventsTableViewController.h"
#import "UIColor+TBAColors.h"
#import <MZFormSheetController/MZFormSheetController.h>
#import <MapKit/MapKit.h>
#import "EventsMapView.h"

#import "EventViewController.h"

@interface EventsTableViewController ()
@property (nonatomic) NSInteger currentYear;
@property (nonatomic, strong) NSDictionary *eventData;
@property (nonatomic, strong) NSDate *seasonStartDate;

@property (nonatomic) BOOL isMapVisible;
@property (nonatomic, strong) EventsMapView *map;
@end

@implementation EventsTableViewController

- (NSDictionary *)eventDataKeyedByShortIndices
{
    NSArray *normalKeys = [self sortedEventGroupKeys];
    NSArray *indexKeys = [self sortedEventIndexTitles];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:normalKeys.count];
    for(int i = 0; i < normalKeys.count; i++) {
        NSString *normalKey = normalKeys[i];
        NSString *indexKey = indexKeys[i];
        id value = self.eventData[normalKey];
        result[indexKey] = value;
    }
    return result;
}

- (EventsMapView *)setupMap
{
    EventsMapView *map = [[EventsMapView alloc] initForAutoLayout];
    map.delegate = map;
    map.alpha = 0;
    [self.view addSubview:map];
    [map autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    map.eventData = [self eventDataKeyedByShortIndices];
    map.sortedIndexTitles = [self sortedEventIndexTitles];
    map.seasonStartDate = self.seasonStartDate;
    
    return map;
}
- (EventsMapView *)map
{
    if (!_map) {
        _map = [self setupMap];
        _map.alpha = 0;
    }
    return _map;
}

- (NSInteger)currentYear
{
    NSInteger year = [[NSUserDefaults standardUserDefaults] integerForKey:@"EventsViewController.currentYear"];
    
    if(year == 0) {
        return 2014;
    }

    return year;
}

- (void)setCurrentYear:(NSInteger)currentYear
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentYear forKey:@"EventsViewController.currentYear"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.title = [NSString stringWithFormat:@"%@ Events", @(currentYear)];
    
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"year == %d", currentYear];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    self.seasonStartDate = [self getSeasonStartDate];
    [self.fetchedResultsController.delegate controllerDidChangeContent:self.fetchedResultsController];
    [self.tableView reloadData];
}

- (NSArray *)sortedEventGroupKeys
{
    NSArray *keys = [self.eventData allKeys];
    
    NSArray *keyOrder = @[@"Championship Event", @"Other Official Events", @"Preseason", @"Offseason"];
    return [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        BOOL key1IsWeek = [key1 rangeOfString:@"Week"].location != NSNotFound;
        BOOL key2IsWeek = [key2 rangeOfString:@"Week"].location != NSNotFound;

        if(key1IsWeek && !key2IsWeek) {
            return NSOrderedAscending;
        } else if(!key1IsWeek && key2IsWeek) {
            return NSOrderedDescending;
        } else if(!key1IsWeek && !key2IsWeek) {
            NSInteger index1 = [keyOrder indexOfObject:key1];
            NSInteger index2 = [keyOrder indexOfObject:key2];
            if(index1 - index2 > 0) {
                return NSOrderedDescending;
            } else if(index1 - index2 < 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        } else {
            int week1 = [[key1 stringByReplacingOccurrencesOfString:@"Week " withString:@""] intValue];
            int week2 = [[key2 stringByReplacingOccurrencesOfString:@"Week " withString:@""] intValue];
            if(week1 - week2 > 0) {
                return NSOrderedDescending;
            } else if(week1 - week2 < 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }
    }];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    if(self.teamFilter) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"year == %d AND %@ in teams", self.currentYear, self.teamFilter];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"year == %d", self.currentYear];
    }
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.fetchBatchSize = 20;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"start_date"
                                                                                   cacheName:nil];
    self.seasonStartDate = [self getSeasonStartDate];
    self.eventData = [self groupEventsByWeek];
    [self.tableView reloadData];
}

- (NSDate *)getSeasonStartDate
{
    NSArray *inSeasonEvents = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"official == 1 && (event_type == %d || event_type == %d)", TBAEventTypeRegional, TBAEventTypeDistrict]];
    
    if ([inSeasonEvents count] == 0) {
        return nil;
    }
    
    Event *firstEvent = [inSeasonEvents firstObject];
    int diffFromThurs = (firstEvent.start_date.weekday - 5) % 7; // Thursday is 5
    
    return [firstEvent.start_date dateBySubtractingDays:diffFromThurs];
}

- (NSInteger)getWeekForEvent:(Event*)event
{
    if (!event.start_date) {
        return -1;
    }
    return ([self.seasonStartDate distanceInDaysToDate:event.start_date] / 7) + 1;
}

- (NSDictionary *)groupEventsByWeek
{
    NSMutableDictionary *eventData = [[NSMutableDictionary alloc] init];

    for (Event *event in self.fetchedResultsController.fetchedObjects) {
        
        NSString *weeklessEventsLabel = @"Other Official Events";
        NSString *preseasonEventsLabel = @"Preseason";
        NSString *offseasonEventsLabel = @"Offseason";
        NSString *cmpEventsLabel = @"Championship Event";
        
        if ([event.official intValue] == 1 && ([event.event_type integerValue] == TBAEventTypeCMPDivision || [event.event_type integerValue] == TBAEventTypeCMPFinals)) {
            [self event:event addToEventList:eventData forLabel:cmpEventsLabel];
        } else if ([event.official intValue] == 1 && ([event.event_type integerValue] == TBAEventTypeRegional || [event.event_type integerValue] == TBAEventTypeDistrict || [event.event_type integerValue] == TBAEventTypeDistrictCMP)) {
            if (event.start_date == nil || (event.start_date.month == 12 && event.start_date.day == 31)) {
                [self event:event addToEventList:eventData forLabel:weeklessEventsLabel];
            } else {
                NSNumber *week = @([self getWeekForEvent:event]);
                NSString *weekLabel = [NSString stringWithFormat:@"Week %@", week];
                
                [self event:event addToEventList:eventData forLabel:weekLabel];
            }
        } else if ([event.event_type integerValue] == TBAEventTypePreseason) {
            [self event:event addToEventList:eventData forLabel:preseasonEventsLabel];
        } else {
            [self event:event addToEventList:eventData forLabel:offseasonEventsLabel];
        }
    }
    return eventData;
}

- (void)event:(Event*)event addToEventList:(NSMutableDictionary*)eventList forLabel:(NSString*)label
{
    if (![eventList objectForKey:label]) {
        eventList[label] = [[NSMutableArray alloc] initWithObjects:event, nil];
    } else {
        [eventList[label] addObject:event];
    }
}

// Override the default insertion of new cells when the database changes
// This disables the automatic animation of new items
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

// Ensures that when the database changes, we properly resort all the data
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.eventData = [self groupEventsByWeek];
    [self.tableView reloadData];
    
    if(self.isMapVisible) {
        self.map.eventData = [self eventDataKeyedByShortIndices];
        self.map.sortedIndexTitles = [self sortedEventIndexTitles];
        self.map.seasonStartDate = self.seasonStartDate;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ Events", @(self.currentYear)];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    self.eventData = [[NSMutableDictionary alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Years" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelectYearScreen)];
}

- (void)showSelectYearScreen
{
    YearSelectView *yearSelectController = [[YearSelectView alloc] initWithDelegate:self currentYear:self.currentYear];
    UINavigationController *formNavController = [[UINavigationController alloc] initWithRootViewController:yearSelectController];

    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:formNavController];
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentAnimated:YES completionHandler:nil];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [[self.eventData allKeys] count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id key = [self sortedEventGroupKeys][section];
    NSInteger numberOfEvents = [self.eventData[key] count];
    return numberOfEvents;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell" forIndexPath:indexPath];
        
    id key = [self sortedEventGroupKeys][indexPath.section];
    NSArray *eventList = self.eventData[key];
    Event *event = eventList[indexPath.row];

    cell.textLabel.text = event.short_name ? event.short_name : event.name;
    cell.detailTextLabel.text = event.location;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id key = [self sortedEventGroupKeys][section];
    return (NSString *)key;
}

- (NSArray *)sortedEventIndexTitles
{
    NSArray *keys = [self sortedEventGroupKeys];
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:keys.count];
    for (NSString *key in keys) {
        NSString *title = nil;
        if([key rangeOfString:@"Week "].location != NSNotFound) {
            title = [key stringByReplacingOccurrencesOfString:@"Week " withString:@"W"];
        } else if([key isEqualToString:@"Championship Event"]) {
            title = @"CMP";
        } else if([key isEqualToString:@"Preseason"]) {
            title = @"Pre";
        } else if([key isEqualToString:@"Offseason"]) {
            title = @"Off";
        } else {
            title = [key substringToIndex:3];
        }
        [titles addObject:title];
    }
    return titles;
}

// Sketchily add empty section index titles to create better spacing
// See http://stackoverflow.com/questions/18923729/uitableview-section-index-spacing-on-ios-7
const int EVENTS_TABLE_SPACES_TO_ADD = 2;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [[self sortedEventIndexTitles] mutableCopy];
    for (int i = 0; i < titles.count; i += (EVENTS_TABLE_SPACES_TO_ADD + 1)) {
        for (int j = 0; j < EVENTS_TABLE_SPACES_TO_ADD; j++) {
            [titles insertObject:@"" atIndex:i+1];
        }
    }
    return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index / (EVENTS_TABLE_SPACES_TO_ADD + 1);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Event"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id key = [self sortedEventGroupKeys][indexPath.section];
        NSArray *eventList = self.eventData[key];
        Event *event = eventList[indexPath.row];

        EventViewController *dest = segue.destinationViewController;
        dest.event = event;
    }
}

- (NSPredicate *)predicateForSearchText:(NSString *)searchText
{
    NSLog(@"We're searching for - %@", searchText);
    if (searchText && searchText.length) {
        return [NSPredicate predicateWithFormat:@"(name contains[cd] %@ OR key contains[cd] %@) && year == %d", searchText, searchText, self.currentYear];
    } else {
        return [NSPredicate predicateWithFormat:@"year == %d", self.currentYear];;
    }
}

#pragma mark - YearSelect protocol method

- (void)didSelectNewYear:(NSInteger)year
{
    self.currentYear = year;
}

#pragma mark - IBActions

- (IBAction)mapButtonTapped:(UIBarButtonItem *)sender
{
    if(!self.isMapVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            self.map.alpha = 1;
        }];
        sender.title = @"List";
        self.isMapVisible = YES;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.map.alpha = 0;
        }];
        sender.title = @"Map";
        self.isMapVisible = NO;
    }
}

@end
