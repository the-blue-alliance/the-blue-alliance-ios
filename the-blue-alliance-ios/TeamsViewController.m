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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"grouping_text" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"team_number" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"grouping_text"
                                                                                   cacheName:nil];
    
}



- (NSString *) controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

// Sketchily add empty section index titles to create better spacing
// See http://stackoverflow.com/questions/18923729/uitableview-section-index-spacing-on-ios-7
const int SPACES_TO_ADD = 3;
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [self.fetchedResultsController.sectionIndexTitles mutableCopy];
    for (int i = 0; i < titles.count; i += (SPACES_TO_ADD + 1)) {
        for (int j = 0; j < SPACES_TO_ADD; j++) {
            [titles insertObject:@"" atIndex:i+1];
        }
    }
    return titles;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index / (SPACES_TO_ADD + 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Team Cell"];
    
    Team *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [team.team_number description];
    cell.detailTextLabel.text = team.nickname;
    
    return cell;
}

- (NSPredicate *) predicateForSearchText:(NSString *)searchText
{
    if(searchText.length > 0) {
        return [NSPredicate predicateWithFormat:@"key contains[cd] %@ OR nickname contains[cd] %@", searchText, searchText, searchText];
    } else {
        return nil;
    }
}


@end
