//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "Team.h"
#import "TeamDetailViewController.h"
#import "MovableAccessoryTableViewCell.h"

@interface TeamsTableViewController ()
@property (nonatomic, strong) NSArray *sections;
@end

#define INDEX_SPACING_PORTRAIT 30
#define INDEX_SPACING_LANDSCAPE 8

@implementation TeamsTableViewController

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    [self setupFetchedResultsControllerUsingContext:context];
    self.sections = [self calculateSectionsForTeams:self.fetchedResultsController.fetchedObjects];

}

- (void)setSections:(NSArray *)sections
{
    _sections = [sections copy];
    [self.indexBar reload];
    [self.tableView reloadData];
}

- (void)setupFetchedResultsControllerUsingContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    if(self.eventFilter) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%@ IN events", self.eventFilter];
    } else {
        fetchRequest.predicate = nil;
    }
    fetchRequest.fetchBatchSize = 20;

    
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
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    
}

- (void)setEventFilter:(Event *)eventFilter
{
    _eventFilter = eventFilter;
    
    self.title = @"Teams";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indexBar = [[GDIIndexBar alloc] initWithTableView:self.tableView];
    self.indexBar.delegate = self;
    [self.view addSubview:self.indexBar];
    self.indexBar.textOffset = UIOffsetMake(7, 15);
    self.indexBar.barWidth = 50;
    self.indexBar.barBackgroundWidth = 50;
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.indexBar.textSpacing = INDEX_SPACING_PORTRAIT;
    } else {
        self.indexBar.textSpacing = INDEX_SPACING_LANDSCAPE;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.indexBar.textSpacing = INDEX_SPACING_PORTRAIT;
    } else {
        self.indexBar.textSpacing = INDEX_SPACING_LANDSCAPE;
    }
}

- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    return self.sections.count;
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    NSString *text = self.sections[index][@"title"];
    return text;
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovableAccessoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team Cell" forIndexPath:indexPath];\
    if(self.eventFilter) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.rightAccessoryInset = 24;
    
    Team *team = self.sections[indexPath.section][@"objects"][indexPath.row];
    cell.textLabel.text = [team.team_number description];
    cell.detailTextLabel.text = team.nickname;
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Team"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Team *team = self.sections[indexPath.section][@"objects"][indexPath.row];

        TeamDetailViewController *dest = segue.destinationViewController;
        dest.team = team;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Team *team = self.sections[indexPath.section][@"objects"][indexPath.row];
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

- (NSArray *)calculateSectionsForTeams:(NSArray *)teams
{
    NSArray *sectionTitles = [[[[NSSet alloc] initWithArray:[teams valueForKey:@"grouping_text"]] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionTitles.count];
    for (NSString *title in sectionTitles) {
        NSArray *groupedTeams = [teams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"grouping_text == %@", title]];
        NSDictionary *section = @{@"objects": groupedTeams, @"title": title};
        [sections addObject:section];
    }
    return sections;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section][@"objects"] count];
}





- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.sections[section][@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}






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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.sections = [self calculateSectionsForTeams:controller.fetchedObjects];
}


@end
