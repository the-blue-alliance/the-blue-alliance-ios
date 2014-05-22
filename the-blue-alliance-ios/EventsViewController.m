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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"start_date"
                                                                                   cacheName:nil];
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
