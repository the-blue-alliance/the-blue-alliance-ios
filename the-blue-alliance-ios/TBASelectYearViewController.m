//
//  SelectYearViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBASelectYearViewController.h"

static NSString *const YearCellReuseIdentifier = @"Year Cell";

@implementation TBASelectYearViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Year";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:YearCellReuseIdentifier];
}

#pragma mark - Interface Methods

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.years count];
}

#pragma mark - TBA Table View Delegate

- (void)configureCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger year = [(NSNumber *)[self.years objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", year];
    if (year == self.currentYear) {
        cell.tintColor = [UIColor primaryBlue];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No years found"];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger year = [(NSNumber *)[self.years objectAtIndex:indexPath.row] integerValue];
    if (self.yearSelectedCallback) {
        self.yearSelectedCallback(year);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
