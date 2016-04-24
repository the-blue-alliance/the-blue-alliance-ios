//
//  SelectYearViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBASelectViewController.h"
#import "Event.h"

static NSString *const SelectCellReuseIdentifier = @"SelectCell";

@implementation TBASelectViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
    self.cellIdentifier = SelectCellReuseIdentifier;
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    if (self.selectType == TBASelectTypeWeek) {
        self.title = @"Select Week";
    } else {
        self.title = @"Select Year";
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.numbers count];
}

#pragma mark - TBA Table View Delegate

- (void)configureCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
    NSNumber *number = [self.numbers objectAtIndex:indexPath.row];
    
    if (self.selectType == TBASelectTypeWeek) {
        cell.textLabel.text = [Event stringForEventOrder:number];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", number.stringValue];
    }
    
    if (number == self.currentNumber) {
        cell.tintColor = [UIColor primaryBlue];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)showNoDataView {
    if (self.selectType == TBASelectTypeWeek) {
        [self showNoDataViewWithText:@"No weeks found"];
    } else {
        [self showNoDataViewWithText:@"No years found"];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSNumber *number = [self.numbers objectAtIndex:indexPath.row];
    if (self.numberSelected) {
        self.numberSelected(number);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
