//
//  TBAYearSelectViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAYearSelectViewController.h"
#import "SelectYearViewController.h"

@interface TBAYearSelectViewController ()

@property (nonatomic, strong) UIBarButtonItem *selectYearBarButtonItem;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;

@end

@implementation TBAYearSelectViewController

#pragma mark - Properities

//- (void)setTitle:(NSString *)title {
//    _title = title;
//    NSLog(@"Title is: %@", title);
//}

- (NSInteger)startYear {
    if (_startYear == 0) {
        _startYear = 1992;
    }
    return _startYear;
}

- (NSUInteger)currentYear {
    NSUInteger year = [[NSUserDefaults standardUserDefaults] integerForKey:[self currentYearUserDefaultsString]];
    
    if (year == 0) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        year = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    }
    return year;
}

- (void)setCurrentYear:(NSUInteger)currentYear {
    [[NSUserDefaults standardUserDefaults] setInteger:currentYear forKey:[self currentYearUserDefaultsString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateYearInterface];
}


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupTapGesture];
    [self updateYearInterface];
}

#pragma mark - Interface Methods

- (void)setupTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectYearButtonTapped:)];
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
}

- (void)updateYearInterface {
    self.titleLabel.text = self.navigationItem.title;
    self.yearLabel.text = [NSString stringWithFormat:@"▾ %zd", self.currentYear];
}

- (void)selectYearButtonTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    SelectYearViewController *selectYearViewController = (SelectYearViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SelectYearViewController"];
    selectYearViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    selectYearViewController.currentYear = self.currentYear;
    selectYearViewController.startYear = self.startYear;
    if (self.yearSelected) {
        selectYearViewController.yearSelectedCallback = self.yearSelected;
    }
    
    [self presentViewController:selectYearViewController animated:YES completion:nil];
}

#pragma mark - Private Methods

- (NSString *)currentYearUserDefaultsString {
    NSString *classString = NSStringFromClass([self class]);
    return [NSString stringWithFormat:@"%@.currentYear", classString];
}

@end
