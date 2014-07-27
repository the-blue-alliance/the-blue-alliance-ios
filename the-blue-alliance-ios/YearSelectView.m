//
//  YearSelectView.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "YearSelectView.h"
#import <MZFormSheetController/MZFormSheetController.h>

@interface YearSelectView ()
@property (nonatomic) NSInteger currentYear;
@property (nonatomic) NSInteger initYear;

@property (nonatomic) NSInteger startYear;
@property (nonatomic) NSInteger endYear;
@end

@implementation YearSelectView

- (instancetype)initWithDelegate:(id)delegate currentYear:(NSInteger)year
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.initYear = year;
        self.currentYear = year;
        
        self.startYear = 1992;
        self.endYear = [NSDate date].year + 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Change Year";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hide)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor TBATintColor];
}

- (void)hide
{
    if (self.initYear != self.currentYear && [self.delegate respondsToSelector:@selector(didSelectNewYear:)]) {
        [self.delegate didSelectNewYear:self.currentYear];
    }

    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.endYear -  self.startYear + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Year Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Year Cell"];
    }
    
    if ((self.endYear - indexPath.row) == self.currentYear) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%d", self.endYear - indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newYearCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([newYearCell.textLabel.text integerValue] == self.currentYear) {
        [self hide];
        return;
    }
    
    self.currentYear = [newYearCell.textLabel.text integerValue];
    
    [tableView reloadData];
    
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });
}

@end
