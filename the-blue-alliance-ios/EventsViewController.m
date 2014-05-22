//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event.h"
#import "EventsViewController.h"
#import "UIColor+TBAColors.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface EventsViewController ()
@property (nonatomic) NSInteger currentYear;
@end

@implementation EventsViewController

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.predicate = nil;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"start_date"
                                                                                   cacheName:nil];
}

// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/helpers/event_helper.py#L29
- (NSDictionary*)groupByWeek
{
    NSString *championshipEventsLabel = @"Championship Event";
    NSString *regionalEventsLabel = @"Week %d";
    NSString *weeklessEventsLabel = @"Other Official Events";
    NSString *offseasonEventsLabel = @"Offseason";
    NSString *preseasonEventsLabel = @"Preseason";

    NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] init];
    
    int currentWeek = 1;
    NSDate *weekStart;
    
    NSMutableArray *weeklessEvents = [[NSMutableArray alloc] init];
    NSMutableArray *offseasonEvents = [[NSMutableArray alloc] init];
    NSMutableArray *preseasonEvents = [[NSMutableArray alloc] init];
    
    for (Event *event in self.fetchedResultsController.fetchedObjects) {
        if ([event.official intValue] == 1 && ([event.event_type integerValue] == CMP_DIVISION || [event.event_type integerValue] == CMP_FINALS))
        {
            if ([toReturn objectForKey:championshipEventsLabel])
                toReturn[championshipEventsLabel] = [toReturn[championshipEventsLabel] arrayByAddingObject:event];
            else
                toReturn[championshipEventsLabel] = @[event];
        }
        else if ([event.official intValue] == 1 && ([event.event_type integerValue] == REGIONAL || [event.event_type integerValue] == DISTRICT || [event.event_type integerValue] == DISTRICT_CMP))
        {
            if (event.start_date == nil || (event.start_date.month == 12 && event.start_date.day == 31))
                [weeklessEvents addObject:event];
            else
            {
                if (weekStart == nil)
                {
                    int diffFromThurs = (event.start_date.weekday - 5) % 7; // Thursday is 5
                    weekStart = [event.start_date dateBySubtractingDays:diffFromThurs];
                }
                
                if ([event.start_date isLaterThanOrEqualDate:[weekStart dateByAddingDays:7]])
                {
                    currentWeek += 1;
                    weekStart = [weekStart dateByAddingDays:7];
                }

                NSString *label = [NSString stringWithFormat:regionalEventsLabel, currentWeek];
                if ([toReturn objectForKey:label])
                    toReturn[label] = [toReturn[label] arrayByAddingObject:event];
                else
                    toReturn[label] = @[event];
            }
        }
        else if ([event.event_type integerValue] == PRESEASON)
            [preseasonEvents addObject:event];
        else
            [offseasonEvents addObject:event];
    }
    
    if ([weeklessEvents count] > 0)
        toReturn[weeklessEventsLabel] = weeklessEvents;
    if ([preseasonEvents count] > 0)
        toReturn[preseasonEventsLabel] = preseasonEvents;
    if ([offseasonEvents count] > 0)
        toReturn[offseasonEventsLabel] = offseasonEvents;
    
    return toReturn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentYear = 2014;
    
    self.title = @"Events";
    
    // Lets make this a gear at some point in time? The action button implies share sheet or something - not changing the displayed data
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSelectYearScreen)];
}

- (void) showSelectYearScreen
{
    YearSelectView *yearSelectController = [[YearSelectView alloc] initWithDelegate:self currentYear:self.currentYear];
    UINavigationController *formNavController = [[UINavigationController alloc] initWithRootViewController:yearSelectController];

    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:formNavController];
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentAnimated:YES completionHandler:nil];
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Event Cell"];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = event.short_name ? event.short_name : event.name;
    cell.detailTextLabel.text = event.location;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    NSDateFormatter *friendlyFormatter = [[NSDateFormatter alloc] init];
    friendlyFormatter.dateStyle = NSDateFormatterMediumStyle;
    return [friendlyFormatter stringFromDate:event.start_date];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor TBATableViewSeparatorColor];
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
        return [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR key contains[cd] %@", searchText, searchText];
    } else {
        return nil;
    }
}

#pragma mark - YearSelect protocol method

- (void)didSelectNewYear:(NSInteger)year
{
    // Reload all the data for the new year
    NSLog(@"Should reload for new year");
}

@end
