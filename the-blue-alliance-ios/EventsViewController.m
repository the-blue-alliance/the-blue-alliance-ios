//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//
#import "EventsViewController.h"
#import "TBAEventsViewController.h"
#import "EventViewController.h"
#import "TBANavigationController.h"
#import "TBASelectYearViewController.h"
#import "TBASelectViewController.h"
#import "Event+Fetch.h"

// TODO: Bring the events view to the current week, like the Android app

static NSString *const EventsViewControllerEmbed = @"EventsViewControllerEmbed";
static NSString *const EventViewControllerSegue  = @"EventViewControllerSegue";

@interface EventsViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;

@property (nonatomic, strong) NSNumber *currentYear;
@property (nonatomic, strong) NSArray<NSNumber *> *years;

@end


@implementation EventsViewController
@synthesize weeks = _weeks;

#pragma mark - Properities

- (void)setWeeks:(NSArray<NSNumber *> *)weeks {
    _weeks = weeks;
    
    if (weeks && !self.currentWeek) {
        NSNumber *week = weeks.firstObject;
        
        self.currentWeek = week;
        self.eventsViewController.week = week;
    }
}

- (void)setCurrentYear:(NSNumber *)currentYear {
    _currentYear = currentYear;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.weekSelected = ^(NSNumber *week) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.eventsViewController cancelRefresh];
        [strongSelf.eventsViewController hideNoDataView];
        
        strongSelf.currentWeek = week;
        strongSelf.eventsViewController.week = week;
    };
    
    [self configureYears];
    [self configureEvents];
    [self updateInterface];
}

#pragma mark - Data Methods

- (void)configureYears {
    // TODO: Check if year + 1 exists (for next-season data trickling in)
    NSNumber *year = [TBASelectYearViewController currentYear];
    self.years = [TBASelectYearViewController yearsBetweenStartYear:1992 endYear:year.integerValue];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
        self.eventsViewController.year = year;
    }
}

- (void)configureEvents {
    __weak typeof(self) weakSelf = self;
    [Event fetchEventsForYear:self.currentYear.integerValue fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error || !events || events.count == 0) {
            strongSelf.eventsViewController.refresh();
        } else {
            strongSelf.weeks = [Event groupEventsByWeek:events];
        }
    }];
}

#pragma mark - Interface Methods

- (void)updateInterface {
    if (self.currentYear) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ Events", self.currentYear];
    } else {
        self.navigationItem.title = @"--- Events";
    }
}

- (IBAction)selectYearButtonTapped:(id)sender {
    if (self.currentYear == 0) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TBANavigationController *navigationController = (TBANavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"TBASelectNavigationController"];
    TBASelectViewController *selectViewController = navigationController.viewControllers.firstObject;
    selectViewController.selectType = TBASelectTypeYear;
    selectViewController.currentNumber = self.currentYear;
    selectViewController.numbers = self.years;
    
    __weak typeof(self) weakSelf = self;
    selectViewController.numberSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.eventsViewController cancelRefresh];
        [strongSelf.eventsViewController hideNoDataView];
        
        strongSelf.currentYear = year;
        strongSelf.eventsViewController.year = year;
        
        strongSelf.currentWeek = nil;
        strongSelf.weeks = nil;
        [strongSelf configureEvents];
    };
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = segue.destinationViewController;
        self.eventsViewController.persistenceController = self.persistenceController;
        if (self.weeks) {
            self.eventsViewController.week = [self.weeks firstObject];
        } else {
            // TODO: Show loading screen
        }
        self.eventsViewController.year = self.currentYear;

        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventsFetched = ^{
            [weakSelf configureEvents];
        };

        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:EventViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.event = event;
        eventViewController.persistenceController = self.persistenceController;
    }
}

@end
