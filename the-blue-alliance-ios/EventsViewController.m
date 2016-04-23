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

// TODO: Bring the events view to the current week, like the Android app

static NSString *const EventsViewControllerEmbed = @"EventsViewControllerEmbed";
static NSString *const EventViewControllerSegue  = @"EventViewControllerSegue";

@interface EventsViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;
@property (nonatomic, weak) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) NSArray<NSNumber *> *eventWeeks;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@end


@implementation EventsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.yearSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.eventsViewController cancelRefresh];
        
        if (strongSelf.segmentedControl) {
            strongSelf.segmentedControl.selectedSegmentIndex = 0;
        }
        [strongSelf.eventsViewController hideNoDataView];
        
        strongSelf.currentYear = year;
        strongSelf.eventsViewController.year = year;
        [strongSelf updateWeek:nil];
        strongSelf.eventWeeks = nil;
        [strongSelf updateInterface];
        [strongSelf configureEvents];
    };
    
    [self configureYears];
    [self configureEvents];
    [self styleInterface];
}

#pragma mark - Data Methods

- (void)updateWeek:(nullable NSNumber *)week {
    if (!week) {
        week = [self.eventWeeks firstObject];
    }
    self.eventsViewController.week = week;
}

- (void)configureYears {
    // TODO: Check if year + 1 exists (for next-season data trickling in)
    
    NSNumber *year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:1992 endYear:year.integerValue];
    
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
            strongSelf.eventWeeks = [Event groupEventsByWeek:events];
            [strongSelf updateInterface];
        }
    }];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor primaryBlue];
    self.navigationItem.title = @"Events";

    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForEventKeys:self.eventWeeks];
    [self segmentedControlValueChanged:self.segmentedControl];
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
        /**
         * Special cases for 2016:
         * Week 1 is actually Week 0.5, eveything else is one less
         * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
         */
        if (num.floatValue == 0.5) {
            [mapped addObject:@"Week 0.5"];
        } else {
            [mapped addObject:[Event stringForEventOrder:[num integerValue]]];
        }
    }];
    
    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = mapped;
        [self.segmentedControl setNeedsDisplay];
        return;
    }

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:mapped];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControl.frame = self.segmentedControlView.frame;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor primaryBlue];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                      NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlView addSubview:self.segmentedControl];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.segmentedControlView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.segmentedControlView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.segmentedControlView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.segmentedControlView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    [self.segmentedControlView addConstraints:@[topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]];
}

- (void)segmentedControlValueChanged:(HMSegmentedControl *)segmentedControl {
    NSNumber *week = [self.eventWeeks objectAtIndex:segmentedControl.selectedSegmentIndex];
    [self updateWeek:week];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;
        self.eventsViewController.persistenceController = self.persistenceController;
        if (self.eventWeeks) {
            self.eventsViewController.week = [self.eventWeeks firstObject];
        } else {
            // TODO: Show loading screen
        }
        self.eventsViewController.year = self.currentYear;

        __weak typeof(self) weakSelf = self;
        [self.eventsViewController setEventsFetched:^{
            [weakSelf configureEvents];
        }];

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
