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
#import "HMSegmentedControl.h"
#import "Event+Fetch.h"
#import <PureLayout/PureLayout.h>

// TODO: Bring the events view to the current week, like the Android app

static NSString *const EventsViewControllerEmbed = @"EventsViewControllerEmbed";
static NSString *const EventViewControllerSegue  = @"EventViewControllerSegue";

@interface EventsViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;
@property (nonatomic, weak) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) NSArray<NSNumber *> *eventWeeks;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger currentSegmentIndex;

@end


@implementation EventsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.eventsViewController hideNoDataView];
        [strongSelf updateRefreshBarButtonItem:YES];
        [strongSelf refreshData];
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf cancelRefresh];
        
        if (strongSelf.segmentedControl) {
            strongSelf.segmentedControl.selectedSegmentIndex = 0;
        }
        [strongSelf.eventsViewController hideNoDataView];
        
        strongSelf.currentYear = selectedYear;
        [strongSelf updatePredicate];
        strongSelf.eventWeeks = nil;
        [strongSelf updateInterface];
        [strongSelf configureEvents];
    };
    
    [self configureYears];
    [self configureEvents];
    [self styleInterface];
}

#pragma mark - Data Methods

- (void)updatePredicate {
    [self updatePredicateForWeek:nil];
}

- (void)updatePredicateForWeek:(nullable NSNumber *)week {
    if (!week) {
        week = [self.eventWeeks firstObject];
    }
    self.eventsViewController.predicate = [NSPredicate predicateWithFormat:@"week == %@ AND year == %@", week, @(self.currentYear)];
}

- (void)configureYears {
    // TODO: Check if year + 1 exists (for next-season data trickling in)
    
    NSInteger year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:1992 endYear:year];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
        [self updatePredicate];
    }
}

- (void)configureEvents {
    __weak typeof(self) weakSelf = self;
    [Event fetchEventsForYear:self.currentYear fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray * _Nullable events, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error || !events || events.count == 0) {
            strongSelf.refresh();
        } else {
            strongSelf.eventWeeks = [Event groupEventsByWeek:events];
            [strongSelf updateInterface];
        }
    }];
}

- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForYear:self.currentYear withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            NSString *errorMessage = @"Unable to load events";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.eventWeeks) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.eventsViewController showNoDataViewWithText:errorMessage];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf configureEvents];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = @"Events";

    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForEventKeys:self.eventWeeks];
    [self segmentedControlChangedValue:self.segmentedControl];
}

- (void)updateSegmentedControlForEventKeys:(NSArray<NSNumber *> *)weeks {
    if (!weeks || [weeks count] == 0) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        return;
    }

    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:weeks.count];
    [weeks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *num = (NSNumber *)obj;
        [mapped addObject:[Event stringForEventOrder:[num integerValue]]];
    }];
    
    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = mapped;
        [self.segmentedControl setNeedsDisplay];
        return;
    }

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:mapped];
    
    self.segmentedControl.frame = self.segmentedControlView.frame;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor TBANavigationBarColor];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlView addSubview:self.segmentedControl];
    
    [self.segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSNumber *week = [self.eventWeeks objectAtIndex:segmentedControl.selectedSegmentIndex];
    [self updatePredicateForWeek:week];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.persistenceController = self.persistenceController;
        
        __weak typeof(self) weakSelf = self;
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
