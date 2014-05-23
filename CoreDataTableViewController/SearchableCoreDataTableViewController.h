//
//  SearchableCoreDataTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/18/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "CoreDataTableViewController.h"

/** A table view controller with a search bar for filtering items. Data
 *  is loaded from the table's fetchedResultsController
 */
@interface SearchableCoreDataTableViewController : CoreDataTableViewController <UISearchBarDelegate>

/** The search bar for filtering the table
 */
@property (nonatomic, strong) UISearchBar *searchBar;

/** Set the predicate to be used, given search text
 *  @param searchText Text entered in to the search bar
 *  @return The predicate to be used to filter resutls
 *  @warning OVERRIDE this method in subclasses to return a predicate used for searching the dataset for a given search text
 */
- (NSPredicate *)predicateForSearchText:(NSString *)searchText;
@end
