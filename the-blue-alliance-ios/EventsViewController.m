//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventsViewController.h"

#import "UIColor+TBAColors.h"

#import "Event.h"

@interface EventsViewController () {
    CGFloat _previousScrollPosition;
    CGFloat _previousScrollDirection;
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *searchHeader;
@end

@implementation EventsViewController

- (void)setContext:(NSManagedObjectContext *)context
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Events";

    // Set up search bar
    [self initSearchHeader];
}

- (void)initSearchHeader
{
    self.searchHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 44.)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.searchHeader.frame];
    self.searchBar.delegate = self;
    [self.searchHeader addSubview:self.searchBar];
    
    self.tableView.tableHeaderView = self.searchHeader;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, self.searchHeader.height)];
}

#pragma mark - Scroll view delegate methods

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
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Event Cell"];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = event.short_name ? event.short_name : event.name;
    cell.detailTextLabel.text = event.location;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    NSDateFormatter *friendlyFormatter = [[NSDateFormatter alloc] init];
    friendlyFormatter.dateStyle = NSDateFormatterMediumStyle;
    return [friendlyFormatter stringFromDate:event.start_date];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor TBATableViewSeparatorColor];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

// Disable section indexing
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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
    
    // Hide the search box after canceling
    [self.tableView setContentOffset:CGPointMake(0., self.searchHeader.height - [self.topLayoutGuide length]) animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (!searchBar || ![searchBar isKindOfClass:[UISearchBar class]])
        searchBar = self.searchBar;
    
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    NSLog(@"New text: %@", text);
}

@end
