//
//  TBADistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/12/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBADistrictsViewController.h"
#import "District.h"

static NSString *const DistrictsCellIdentifier  = @"DistrictsCell";

@implementation TBADistrictsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (void)setYear:(NSUInteger)year {
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:[self cacheName]];
    
    _year = year;
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"District"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@", @(self.year)];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:[self cacheName]];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
}

#pragma mark - Private Method

- (NSString *)cacheName {
    return [NSString stringWithFormat:@"%zd_districts", self.year];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    } else {
        // TODO: Show no data screen;
        count = 0;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DistrictsCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    District *district = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = district.name;

}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.districtSelected) {
        return;
    }
    
    District *district = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.districtSelected(district);
}

@end
