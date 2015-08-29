//
//  TBATableViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/11/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"
#import "TBANoDataViewController.h"
#import <PureLayout/PureLayout.h>

@interface TBATableViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;

@end

@implementation TBATableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - TBA Delegate Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([self.tbaDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - No Data Views

- (void)showNoDataViewWithText:(NSString *)text {
    self.noDataViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    
    self.noDataViewController.view.alpha = 0.0f;
    [self.tableView setBackgroundView:self.noDataViewController.view];
    
    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.noDataViewController.view.alpha = 1.0f;
    }];
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        [self.tableView setBackgroundView:nil];
    }
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
