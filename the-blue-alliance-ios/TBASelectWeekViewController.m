//
//  TBASelectWeekViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/24/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBASelectWeekViewController.h"
#import "TBANavigationController.h"
#import "TBASelectViewController.h"
#import "Event.h"

@implementation TBASelectWeekViewController

#pragma mark - Class Methods

+ (NSNumber *)currentWeek {
    // TODO: Look at the Android code to figure out how they determine the current week
    return nil;
}

#pragma mark - Properities

- (void)setCurrentWeek:(NSNumber *)currentWeek {
    _currentWeek = currentWeek;

    [self updateWeekInterface];
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupTapGesture];
    [self updateWeekInterface];
}

#pragma mark - Interface Methods

- (void)setupTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectWeekButtonTapped:)];
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
}

- (void)updateWeekInterface {
    self.navigationTitleLabel.text = self.navigationItem.title;
    if (!self.currentWeek) {
        self.navigationSubtitleLabel.text = @"---";
    } else {
        self.navigationSubtitleLabel.text = [NSString stringWithFormat:@"▾ %@", [Event stringForEventOrder:self.currentWeek]];
    }
}

- (void)selectWeekButtonTapped:(id)sender {
    if (!self.currentWeek) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TBANavigationController *navigationController = (TBANavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"TBASelectNavigationController"];
    TBASelectViewController *selectViewController = navigationController.viewControllers.firstObject;
    selectViewController.selectType = TBASelectTypeWeek;
    selectViewController.currentNumber = self.currentWeek;
    selectViewController.numbers = self.weeks;
    if (self.weekSelected) {
        selectViewController.numberSelected = self.weekSelected;
    }
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
