//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event.h"
#import "EventGroup.h"
#import "EventsTableViewController.h"
#import "UIColor+TBAColors.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface EventsTableViewController ()
@property (nonatomic) NSInteger currentYear;
@property (nonatomic, strong) NSArray *eventData;
@end

@implementation EventsTableViewController

- (NSInteger) currentYear
{
    int year = [[NSUserDefaults standardUserDefaults] integerForKey:@"EventsViewController.currentYear"];
    if(year == 0) {
        return 2014;
    }
    return year;
}

- (void) setCurrentYear:(NSInteger)currentYear
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentYear forKey:@"EventsViewController.currentYear"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.title = [NSString stringWithFormat:@"%d Events", currentYear];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"year == %d", self.currentYear];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"start_date"
                                                                                   cacheName:nil];
    self.eventData = [self groupEventsByWeek];
    [self.tableView reloadData];
}

// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/helpers/event_helper.py#L29
- (NSArray *)groupEventsByWeek
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    int currentWeek = 1;
    NSDate *weekStart;
    
    EventGroup *weeklessEvents = [[EventGroup alloc] initWithName:@"Other Official Events"];
    EventGroup *preseasonEvents = [[EventGroup alloc] initWithName:@"Preseason"];
    EventGroup *offseasonEvents = [[EventGroup alloc] initWithName:@"Offseason"];
    EventGroup *cmpEvents = [[EventGroup alloc] initWithName:@"Championship Event"];
    EventGroup *currentWeekEvents;
    
    for (Event *event in self.fetchedResultsController.fetchedObjects) {
        if ([event.official intValue] == 1 && ([event.event_type integerValue] == CMP_DIVISION || [event.event_type integerValue] == CMP_FINALS))
            [cmpEvents addEvent:event];
        else if ([event.official intValue] == 1 && ([event.event_type integerValue] == REGIONAL || [event.event_type integerValue] == DISTRICT || [event.event_type integerValue] == DISTRICT_CMP))
        {
            if (event.start_date == nil || (event.start_date.month == 12 && event.start_date.day == 31))
                [weeklessEvents addEvent:event];
            else
            {
                if (weekStart == nil)
                {
                    int diffFromThurs = (event.start_date.weekday - 5) % 7; // Thursday is 5
                    weekStart = [event.start_date dateBySubtractingDays:diffFromThurs];
                }
                
                if ([event.start_date isLaterThanOrEqualDate:[weekStart dateByAddingDays:7]])
                {
                    [toReturn addObject:currentWeekEvents];
                    currentWeekEvents = nil;
                    currentWeek += 1;
                    weekStart = [weekStart dateByAddingDays:7];
                }

                if (!currentWeekEvents)
                {
                    NSString *label = [NSString stringWithFormat:@"Week %d", currentWeek];
                    currentWeekEvents = [[EventGroup alloc] initWithName:label];
                }
                
                [currentWeekEvents addEvent:event];
            }
        }
        else if ([event.event_type integerValue] == PRESEASON)
            [preseasonEvents addEvent:event];
        else
            [offseasonEvents addEvent:event];
    }
    
    // Add last week that was not added in the loop
    if(currentWeekEvents.events.count > 0) {
        [toReturn addObject:currentWeekEvents];
    }
    
    if ([cmpEvents.events count] > 0)
        [toReturn addObject:cmpEvents];
    if ([weeklessEvents.events count] > 0)
        [toReturn addObject:weeklessEvents];
    if ([preseasonEvents.events count] > 0)
        [toReturn addObject:preseasonEvents];
    if ([offseasonEvents.events count] > 0)
        [toReturn addObject:offseasonEvents];
    
    return toReturn;
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
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.eventData = [self groupEventsByWeek];
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%d Events", self.currentYear];

    
    // Lets make this a gear at some point in time? The action button implies share sheet or something - not changing the displayed data
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
    NSInteger sections = [self.eventData count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EventGroup *eventGroup = [self.eventData objectAtIndex:section];
    return [eventGroup.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Event Cell"];
    
    EventGroup *eventGroup = [self.eventData objectAtIndex:indexPath.section];
    Event *event = [eventGroup.events objectAtIndex:indexPath.row];

    cell.textLabel.text = event.short_name ? event.short_name : event.name;
    cell.detailTextLabel.text = event.location;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EventGroup *eventGroup = [self.eventData objectAtIndex:section];
    return eventGroup.name;
}

// Disable section indexing
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSPredicate *) predicateForSearchText:(NSString *)searchText
{
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
    [[NSUserDefaults standardUserDefaults] setInteger:year forKey:@"EventsViewController.currentYear"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"year == %d", self.currentYear];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    [self.fetchedResultsController.delegate controllerDidChangeContent:self.fetchedResultsController];
    [self.tableView reloadData];
}

@end
