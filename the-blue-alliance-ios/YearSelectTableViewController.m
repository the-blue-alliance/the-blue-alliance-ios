//
//  YearSelectTableView.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <POP/POP.h>

#import "YearSelectTableViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface YearSelectTableViewController ()

@end

@implementation YearSelectTableViewController

const int kNumberOfYears = 23;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.currentYear = 2014;
    
    self.navigationItem.title = @"Change Year";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hide)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor TBATintColor];
}



- (void) hide
{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}




#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfYears;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Year Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Year Cell"];
    
    if ((2014 - indexPath.row) == self.currentYear)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%ld", 2014l - indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newYearCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([newYearCell.textLabel.text integerValue] == self.currentYear) {
//        [self hide];
        return;
    }
    
    self.currentYear = [newYearCell.textLabel.text integerValue];
    
    [tableView reloadData];
    
    // call some method to reload the backing data here?
    // Maybe store year in NSUserDefaults, and perhaps use NSNotification to broadcast change?
    
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
//        [self hide];
    });
}

@end
