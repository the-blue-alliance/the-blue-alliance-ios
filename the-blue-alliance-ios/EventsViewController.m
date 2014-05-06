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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Replace with some customized cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Event Cell"];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell" forIndexPath:indexPath];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = event.name;
    
    return cell;
}

@end
