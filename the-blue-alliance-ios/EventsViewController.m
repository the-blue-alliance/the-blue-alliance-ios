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
@property (nonatomic, strong) IBOutlet UIView *eventsView;

@property (nonatomic, strong) NSNumber *currentWeek;
@property (nonatomic, strong) NSArray<NSNumber *> *weeks;

@end


@implementation EventsViewController

#pragma mark - Properities

- (void)setWeeks:(NSArray<NSNumber *> *)weeks {
    _weeks = weeks;
    
    if (weeks && !self.currentWeek) {
        NSNumber *week = weeks.firstObject;
        
        self.currentWeek = week;
        self.eventsViewController.week = week;
    }
}

- (void)setCurrentWeek:(NSNumber *)currentWeek {
    _currentWeek = currentWeek;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self styleInterface];
    });
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.eventsViewController];
    self.containerViews = @[self.eventsView];
    
    __weak typeof(self) weakSelf = self;
    self.yearSelected = ^(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf cancelRefreshes];

        strongSelf.currentYear = year;
        strongSelf.eventsViewController.year = year;

        strongSelf.currentWeek = nil;
        strongSelf.weeks = nil;
        [strongSelf configureEvents];
    };
    
    [self configureYears];
    [self configureEvents];
    
    [self styleInterface];
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
        strongSelf.weeks = [Event groupEventsByWeek:events];
    }];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    NSString *titleString;
    if (self.currentWeek) {
        titleString = [Event stringForEventOrder:self.currentWeek];
    } else {
        titleString = @"--- Events";
    }
    
    self.navigationTitleLabel.text = titleString;
    self.navigationItem.title = titleString;
}

- (IBAction)selectWeekButtonTapped:(id)sender {
    if (!self.currentWeek) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TBANavigationController *navigationController = (TBANavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"TBASelectNavigationController"];
    TBASelectViewController *selectViewController = navigationController.viewControllers.firstObject;
    selectViewController.selectType = TBASelectTypeWeek;
    selectViewController.currentNumber = self.currentWeek;
    selectViewController.numbers = self.weeks;
    
    __weak typeof(self) weakSelf = self;
    selectViewController.numberSelected = ^(NSNumber *week) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf cancelRefreshes];

        strongSelf.currentWeek = week;
        strongSelf.eventsViewController.week = week;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self styleInterface];
        });
    };

    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = segue.destinationViewController;
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
    }
}

@end
