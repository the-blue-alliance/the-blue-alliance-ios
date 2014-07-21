//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "Team.h"

@interface TeamsTableViewController ()

@end

@implementation TeamsTableViewController

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    [self setupFetchedResultsControllerUsingContext:context];
    
}

- (void)setupFetchedResultsControllerUsingContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    if(self.eventFilter) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ IN events", self.eventFilter];
    } else {
        fetchRequest.predicate = nil;
    }
    
    if(self.disableSections) {
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"team_number" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"grouping_text" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"team_number" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:@"grouping_text"
                                                                                       cacheName:nil];
    }
    
}

- (void)setEventFilter:(Event *)eventFilter
{
    _eventFilter = eventFilter;
//    if(_eventFilter) {
//        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ IN events", _eventFilter];
//    } else {
//        self.fetchedResultsController.fetchRequest.predicate = nil;
//    }
    self.title = @"Teams";
}

- (void)setDisableSections:(BOOL)disableSections
{
    _disableSections = disableSections;
    if(self.context) {
//        [self setupFetchedResultsControllerUsingContext:self.context];
    }
}



- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

// Sketchily add empty section index titles to create better spacing
// See http://stackoverflow.com/questions/18923729/uitableview-section-index-spacing-on-ios-7
const int SPACES_TO_ADD = 3;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [self.fetchedResultsController.sectionIndexTitles mutableCopy];
    for (int i = 0; i < titles.count; i += (SPACES_TO_ADD + 1)) {
        for (int j = 0; j < SPACES_TO_ADD; j++) {
            [titles insertObject:@"" atIndex:i+1];
        }
    }
    return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index / (SPACES_TO_ADD + 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Team Cell"];
    }
    
    Team *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [team.team_number description];
    cell.detailTextLabel.text = team.nickname;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSPredicate *)predicateForSearchText:(NSString *)searchText
{
    if(searchText.length > 0) {
        if(self.eventFilter) {
            return [NSPredicate predicateWithFormat:@"(key contains[cd] %@ OR nickname contains[cd] %@) AND %@ in events", searchText, searchText, self.eventFilter];
        } else {
            return [NSPredicate predicateWithFormat:@"key contains[cd] %@ OR nickname contains[cd] %@", searchText, searchText];
        }
    } else {
        if(self.eventFilter) {
            return [NSPredicate predicateWithFormat:@"%@ in events", self.eventFilter];
        } else {
            return nil;
        }
    }
}


@end
