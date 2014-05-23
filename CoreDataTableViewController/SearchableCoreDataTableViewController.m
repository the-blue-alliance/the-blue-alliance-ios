//
//  SearchableCoreDataTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/18/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "SearchableCoreDataTableViewController.h"

@interface SearchableCoreDataTableViewController () {
    CGFloat _previousScrollPosition;
    CGFloat _previousScrollDirection;
}
@property (nonatomic, strong) UIView *searchHeader;

@end

@implementation SearchableCoreDataTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initSearchHeader];
}

- (void)initSearchHeader
{
    self.searchHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 44.)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.searchHeader.frame];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"Search";
    
    [self.searchHeader addSubview:self.searchBar];
    
    self.tableView.tableHeaderView = self.searchHeader;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, self.searchHeader.height)];
}


/*#pragma mark - Scroll view delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollOffset = scrollView.contentOffset.y;
    
    if ((int)_previousScrollPosition != (int)scrollOffset)
    {
        if (_previousScrollPosition < scrollOffset)
            _previousScrollDirection = 1;
        else
            _previousScrollDirection = -1;
        
        _previousScrollPosition = scrollOffset;
    }
    
    if(scrollOffset == 0)
    {
        [self.searchBar becomeFirstResponder];
    }
    else if(scrollOffset >= self.searchHeader.height && self.searchBar.text.length == 0)
    {
        [self.searchBar resignFirstResponder];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat searchTop = self.searchHeader.y - self.tableView.contentInset.top;
    CGFloat searchBottom = self.searchHeader.bottom - self.tableView.contentInset.top;
    
    if (targetContentOffset->y > searchTop &&
        targetContentOffset->y < searchBottom)
    {
        if (velocity.y == 0)
            targetContentOffset->y = _previousScrollDirection > 0 ? searchBottom : searchTop;
        else if (velocity.y < 0)
            targetContentOffset->y = searchTop;
        else
            targetContentOffset->y = searchBottom;
    }
}*/


#pragma mark - UISearchBarDelegate Methods

#define KeyboardHeight 216.
#define TabBarHeight 50.

- (CGFloat)searchBarStaticHeaderHeight
{
    return self.searchHeader.height;
}

- (CGFloat)searchBarTableResizeHeight
{
    // Subtract the tab bar height from the keyboard height because the keyboard covers the tab bar
    return KeyboardHeight - TabBarHeight;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    
    self.fetchedResultsController.fetchRequest.predicate = nil;
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    // Hide the search bar
    [self.tableView setContentOffset:CGPointMake(0., self.searchHeader.height - [self.topLayoutGuide length]) animated:YES];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self filterContentForSearchText:text];
}

- (void)filterContentForSearchText:(NSString *)searchText
{
    NSPredicate *predicate = [self predicateForSearchText:searchText];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"An error happened and we should handle it - %@", error.localizedDescription);
    }
    
    [self.tableView reloadData];
}

- (NSPredicate *)predicateForSearchText:(NSString *)searchText
{
    return nil;
}




@end
