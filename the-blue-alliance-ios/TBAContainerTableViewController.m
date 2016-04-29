//
//  TBAContainerTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/11/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAContainerTableViewController.h"
#import "TBANoDataViewController.h"

@interface TBAContainerTableViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;

@end

@implementation TBAContainerTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64.0f;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:(239.0f/255.0f) green:(239.0f/255.0f) blue:(244.0f/255.0f) alpha:1.0f];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - TBA Delegate Methods

- (void)configureCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self.tbaDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - Public Methods

- (void)clearFRC {
    self.fetchedResultsController = nil;
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)showNoDataViewWithText:(NSString *)text {
    if (!self.noDataViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.noDataViewController = [storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    }
    
    self.noDataViewController.view.alpha = 0.0f;

    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView setBackgroundView:self.noDataViewController.view];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.noDataViewController.view.alpha = 1.0f;
        }];
    });
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView setBackgroundView:nil];
        });
    }
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        sections = self.fetchedResultsController.sections.count;
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        rows = [sectionInfo numberOfObjects];
        if (!rows || (rows && rows == 0 && self.tbaDelegate)) {
            [self.tbaDelegate showNoDataView];
        } else {
            [self hideNoDataView];
        }
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (self.tbaDelegate) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
