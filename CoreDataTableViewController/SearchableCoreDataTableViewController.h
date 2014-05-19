//
//  SearchableCoreDataTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/18/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface SearchableCoreDataTableViewController : CoreDataTableViewController <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

// OVERRIDE this method in subclasses to return a predicate used for searching the dataset for a given search text
- (NSPredicate *) predicateForSearchText:(NSString *)searchText;
@end
