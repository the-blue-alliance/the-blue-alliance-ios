//
//  SelectYearViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "SelectYearViewController.h"


static NSString *const YearCellReuseIdentifier = @"Year Cell";


@implementation SelectYearViewController
/*
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:YearCellReuseIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    NSDate *current = [NSDate date];
    return (current.year - self.startYear) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YearCellReuseIdentifier forIndexPath:indexPath];
    
    NSDate *current = [NSDate date];
    NSUInteger year = current.year - indexPath.row;

    cell.textLabel.text = [NSString stringWithFormat:@"%ld", year];
    if (year == self.currentYear) {
        cell.tintColor = [UIColor TBANavigationBarColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDate *current = [NSDate date];
    NSUInteger year = current.year - indexPath.row;
    
    if (self.yearSelectedCallback) {
        self.yearSelectedCallback(year);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/

@end
