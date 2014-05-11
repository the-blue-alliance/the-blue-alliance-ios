//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventsViewController.h"
#import "Event.h"

@interface EventsViewController ()

@end

@implementation EventsViewController

- (void) setContext:(NSManagedObjectContext *)context
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

- (void) viewDidLoad
{
    [super viewDidLoad];
        
    // TODO: Replace with some customized cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Event Cell"];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell" forIndexPath:indexPath];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = event.name;
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    NSDateFormatter *friendlyFormatter = [[NSDateFormatter alloc] init];
    friendlyFormatter.dateStyle = NSDateFormatterMediumStyle;
    return [friendlyFormatter stringFromDate:event.start_date];
}

// Disable section indexing
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

@end
