//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//
#import "EventsViewController.h"
#import "SelectYearViewController.h"
#import "SelectYearTransitionAnimator.h"
#import "HMSegmentedControl.h"
#import "UIColor+TBAColors.h"
#import "TBAApp.h"
#import "TBAImporter.h"
#import "TBAKit.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "OrderedDictionary.h"
#import "District.h"
#import "EventsCollectionViewController.h"
#import "EventsCollectionViewCell.h"
#import "EventViewController.h"
#import <PureLayout/PureLayout.h>

#warning bring this to the current week like the Android app

static NSString *const WeeklessEventsLabel      = @"Other Official Events";
static NSString *const PreseasonEventsLabel     = @"Preseason";
static NSString *const OffseasonEventsLabel     = @"Offseason";
static NSString *const CMPEventsLabel           = @"Championship Event";


@interface EventsViewController () <UICollectionViewDelegateFlowLayout>

// Ordered dict of "Weeks" (Preseason, Week 1, Week 2, ...)
// Week dicts have ordered dict of event types (Regional Events, MI District Events, ...)
// Event dicts have arrays of events
@property (nonatomic, strong) OrderedDictionary *eventData;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) EventsCollectionViewController *eventsCollectionViewController;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@end


@implementation EventsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            [strongSelf refreshData];
        }
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.segmentedControl) {
            strongSelf.segmentedControl.selectedSegmentIndex = 0;
        }
        strongSelf.currentYear = selectedYear;
        strongSelf.navigationItem.title = [NSString stringWithFormat:@"%@ Events", @(selectedYear)];
        
        [strongSelf cancelRefresh];
        [strongSelf updateRefreshBarButtonItem:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf fetchEvents];
            [strongSelf updateInterface];
        });
    };
    
    [self fetchEvents];
    [self styleInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventTapped:) name:EventTapped object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventTapped object:nil];
}


#pragma mark - Data Methods

- (OrderedDictionary *)groupEventsByWeek:(NSArray *)events {
    MutableOrderedDictionary *eventData = [[MutableOrderedDictionary alloc] init];

    int currentWeek = 1;
    NSDate *weekStart;
    
    NSMutableArray *weeklessEvents = [[NSMutableArray alloc] init];
    NSMutableArray *offseasonEvents = [[NSMutableArray alloc] init];
    NSMutableArray *preseasonEvents = [[NSMutableArray alloc] init];
    NSMutableArray *championshipEvents = [[NSMutableArray alloc] init];
    
    for (Event *event in events) {
        if ([event.official intValue] == 1 && ([event.event_type integerValue] == TBAEventTypeCMPDivision || [event.event_type integerValue] == TBAEventTypeCMPFinals)) {
            [championshipEvents addObject:event];
        } else if ([event.official intValue] == 1 && [@[@(TBAEventTypeRegional), @(TBAEventTypeDistrict), @(TBAEventTypeDistrictCMP)] containsObject:@([event.event_type integerValue])]) {
            if (event.start_date == nil || (event.start_date.month == 12 && event.start_date.day == 31)) {
                [weeklessEvents addObject:event];
            } else {
                if (weekStart == nil) {
                    int diffFromThurs = (event.start_date.weekday - 4) % 7; // Wednesday is 4
                    weekStart = [event.start_date dateBySubtractingDays:diffFromThurs];
                }
                
                if ([event.start_date isLaterThanOrEqualDate:[weekStart dateByAddingDays:7]]) {
                    NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
                    NSArray *weekEvents = [eventData objectForKey:weekLabel];
                    [eventData setValue:[self sortedEventDictionaryFromEvents:weekEvents] forKey:weekLabel];

                    currentWeek += 1;
                    weekStart = [weekStart dateByAddingDays:7];
                }
                
                NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
                if ([eventData objectForKey:weekLabel]) {
                    NSMutableArray *weekArray = [eventData objectForKey:weekLabel];
                    [weekArray addObject:event];
                } else {
                    [eventData setValue:[[NSMutableArray alloc] initWithObjects:event, nil] forKey:weekLabel];
                }
            }
        } else if ([event.event_type integerValue] == TBAEventTypePreseason) {
            [preseasonEvents addObject:event];
        } else {
            [offseasonEvents addObject:event];
        }
    }
    // Put the last week in
    NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
    NSArray *weekEvents = [eventData objectForKey:weekLabel];
    if (weekEvents && [weekEvents count] > 0) {
        [eventData setValue:[self sortedEventDictionaryFromEvents:weekEvents] forKey:weekLabel];
    }
    
    if ([preseasonEvents count] > 0) {
        [eventData insertObject:[self sortedEventDictionaryFromEvents:preseasonEvents]
                         forKey:PreseasonEventsLabel
                        atIndex:0];
    }
    if ([championshipEvents count] > 0) {
        [eventData setValue:[self sortedEventDictionaryFromEvents:championshipEvents] forKey:CMPEventsLabel];
    }
    if ([offseasonEvents count] > 0) {
        [eventData setValue:[self sortedEventDictionaryFromEvents:offseasonEvents] forKey:OffseasonEventsLabel];
    }
    if ([weeklessEvents count] > 0) {
        [eventData setValue:[self sortedEventDictionaryFromEvents:weeklessEvents] forKey:WeeklessEventsLabel];
    }
    
    
    return eventData;
}

- (OrderedDictionary *)sortedEventDictionaryFromEvents:(NSArray *)events {
    // Preseason < Regionals < Districts (MI, MAR, NE, PNW, IN), CMP Divisions, CMP Finals, Offseason, others
    MutableOrderedDictionary *sortedDictionary = [[MutableOrderedDictionary alloc] init];
    
    for (NSNumber *eventType in [Event eventTypes]) {
        if ([eventType integerValue] == TBAEventTypeDistrict) {
            // Sort districts
            for (NSNumber *districtType in [District districtTypes]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_district = %@ AND (NOT event_type = %@)", districtType, @(TBAEventTypeDistrictCMP)];
                NSArray *arr = [events filteredArrayUsingPredicate:predicate];

                if (arr && [arr count] > 0) {
                    NSString *districtTypeLabel;
                    switch ([districtType integerValue]) {
                        case TBADistrictTypeMichigan:
                            districtTypeLabel = @"Michigan District Events";
                            break;
                        case TBADistrictTypeMidAtlantic:
                            districtTypeLabel = @"Mid Atlantic District Events";
                            break;
                        case TBADistrictTypeNewEngland:
                            districtTypeLabel = @"New England District Events";
                            break;
                        case TBADistrictTypePacificNorthwest:
                            districtTypeLabel = @"Pacific Northwest District Events";
                            break;
                        case TBADistrictTypeIndiana:
                            districtTypeLabel = @"Indiana District Events";
                            break;
                        default:
                            break;
                    }
                    [sortedDictionary setValue:arr forKey:districtTypeLabel];
                }
            }
        } else {
            // Sort non-districts
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_type = %@", eventType];
            NSArray *arr = [events filteredArrayUsingPredicate:predicate];
            
            if (arr && [arr count] > 0) {
                NSString *eventTypeLabel;
                switch ([eventType integerValue]) {
                    case TBAEventTypeRegional:
                        eventTypeLabel = @"Regional Events";
                        break;
                    case TBAEventTypeDistrictCMP:
                        eventTypeLabel = @"District Championships";
                        break;
                    case TBAEventTypeCMPDivision:
                        eventTypeLabel = @"Championship Divisions";
                        break;
                    case TBAEventTypeCMPFinals:
                        eventTypeLabel = @"Championship Finals";
                        break;
                    case TBAEventTypeOffseason:
                        eventTypeLabel = @"Offseason Events";
                        break;
                    case TBAEventTypePreseason:
                        eventTypeLabel = @"Preseason Events";
                        break;
                    case TBAEventTypeUnlabeled:
                        eventTypeLabel = @"Other Official Events";
                        break;
                    default:
                        eventTypeLabel = @"";
                        break;
                }
                [sortedDictionary setValue:arr forKey:eventTypeLabel];
            }
        }
    }
    
    return sortedDictionary;
}

- (void)fetchEvents {
    self.eventData = nil;
    
    NSArray *events = [Event fetchEventsForYear:self.currentYear fromContext:[TBAApp managedObjectContext]];
    if (!events || [events count] == 0) {
        if (self.refresh) {
            self.refresh();
        }
    } else {
        self.eventData = [self groupEventsByWeek:events];
    }
}

- (void)refreshData {
    NSInteger year = self.currentYear;
    
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"events/%@", @(year)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;

        if (error) {
            NSLog(@"Error loading events: %@", error.localizedDescription);
        }
        if (!error && [objects isKindOfClass:[NSArray class]]) {
            [TBAImporter importEvents:objects];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateRefreshBarButtonItem:NO];

            [self fetchEvents];
            [self updateInterface];
        });
    }];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Events", @(self.currentYear)];
    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForEventKeys:self.eventData.allKeys];
    self.eventsCollectionViewController.eventData = self.eventData;
    [self.eventsCollectionViewController.collectionView reloadData];
}

- (void)updateSegmentedControlForEventKeys:(NSArray *)eventKeys {
    if (!eventKeys || [eventKeys count] == 0) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        return;
    }

    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = eventKeys;
        [self.segmentedControl setNeedsDisplay];
        return;
    }

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:eventKeys];
    
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
    [self.eventsCollectionViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:segmentedControl.selectedSegmentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


#pragma mark - Collection View Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.eventsCollectionViewController.collectionView.frame.size;
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.eventsCollectionViewController.collectionView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}


#pragma mark - Navigation

- (void)eventTapped:(NSNotification *)notification {
    Event *event = notification.object;
    [self performSegueWithIdentifier:@"EventViewControllerSegue" sender:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventsCollectionViewControllerEmbedSegue"]) {
        EventsCollectionViewController *eventsCollectionViewController = segue.destinationViewController;
        eventsCollectionViewController.collectionView.delegate = self;
        self.eventsCollectionViewController = eventsCollectionViewController;
    } else if ([segue.identifier isEqualToString:@"EventViewControllerSegue"]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.event = event;
    }
}


/*
- (NSPredicate *)predicateForSearchText:(NSString *)searchText
{
    NSLog(@"We're searching for - %@", searchText);
    if (searchText && searchText.length) {
        return [NSPredicate predicateWithFormat:@"(name contains[cd] %@ OR key contains[cd] %@) && year == %d", searchText, searchText, self.currentYear];
    } else {
        return [NSPredicate predicateWithFormat:@"year == %d", self.currentYear];;
    }
}
*/


@end
