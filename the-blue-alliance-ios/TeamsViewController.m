//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "Team.h"

@interface TeamsViewController ()

@end

@implementation TeamsViewController

- (void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    fetchRequest.predicate = nil;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"team_number" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Event Cell"];
    
    Team *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [team.team_number description];
    cell.detailTextLabel.text = team.nickname;
    
    return cell;
}


@end
