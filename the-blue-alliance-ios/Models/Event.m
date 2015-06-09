//
//  Event.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event.h"
#import "District.h"
#import "EventAlliance.h"
#import "EventWebcast.h"
#import "OrderedDictionary.h"


static NSString *const WeeklessEventsLabel      = @"Other Official Events";
static NSString *const PreseasonEventsLabel     = @"Preseason";
static NSString *const OffseasonEventsLabel     = @"Offseason";
static NSString *const CMPEventsLabel           = @"Championship Event";


@implementation Event

@dynamic key;
@dynamic name;
@dynamic shortName;
@dynamic eventCode;
@dynamic eventType;
@dynamic eventDistrict;
@dynamic year;
@dynamic location;
@dynamic venueAddress;
@dynamic website;
@dynamic facebookEid;
@dynamic official;
@dynamic startDate;
@dynamic endDate;
@dynamic webcasts;
@dynamic alliances;

- (NSDate *)dateStart {
    return [NSDate dateWithTimeIntervalSince1970:self.startDate];
}

- (NSDate *)dateEnd {
    return [NSDate dateWithTimeIntervalSince1970:self.endDate];
}

- (NSString *)friendlyNameWithYear:(BOOL)withYear {
    NSString *nameString;
    if (withYear) {
        nameString = [NSString stringWithFormat:@"%@ %@", [@(self.year) stringValue], self.shortName ? self.shortName : self.name];
    } else {
        nameString = [NSString stringWithFormat:@"%@", self.shortName ? self.shortName : self.name];
    }
    
    NSString *typeSuffix = @"";
    switch (self.eventType) {
        case TBAEventTypeRegional:
            typeSuffix = @"Regional";
            break;
        case TBAEventTypeDistrict:
            typeSuffix = @"District";
            break;
        case TBAEventTypeDistrictCMP:
            typeSuffix = @"District CMP";
            break;
        case TBAEventTypeCMPDivision:
            typeSuffix = @"Division";
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@", nameString, typeSuffix];
}

- (NSString *)dateString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
    [endDateFormatter setDateFormat:@"MMM dd, y"];
    
    NSString *dateText;
    if ([calendar component:NSCalendarUnitYear fromDate:[self dateStart]] == [calendar component:NSCalendarUnitYear fromDate:[self dateEnd]]) {
        NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
        [startDateFormatter setDateFormat:@"MMM dd"];
        
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [startDateFormatter stringFromDate:[self dateStart]],
                    [endDateFormatter stringFromDate:[self dateEnd]]];
        
    } else {
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [endDateFormatter stringFromDate:[self dateStart]],
                    [endDateFormatter stringFromDate:[self dateEnd]]];
    }
    
    return dateText;
}

#pragma mark - Class Methods

+ (OrderedDictionary *)groupEventsByWeek:(NSArray *)events andGroupByType:(BOOL)groupByType {
    MutableOrderedDictionary *eventData = [[MutableOrderedDictionary alloc] init];
    
    int currentWeek = 1;
    NSDate *weekStart;
    
    NSMutableArray *weeklessEvents = [[NSMutableArray alloc] init];
    NSMutableArray *offseasonEvents = [[NSMutableArray alloc] init];
    NSMutableArray *preseasonEvents = [[NSMutableArray alloc] init];
    NSMutableArray *championshipEvents = [[NSMutableArray alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (Event *event in events) {
        if (event.official && (event.eventType == TBAEventTypeCMPDivision || event.eventType == TBAEventTypeCMPFinals)) {
            [championshipEvents addObject:event];
        } else if (event.official && [@[@(EventTypeRegional), @(EventTypeDistrict), @(EventTypeDistrictCMP)] containsObject:@(event.eventType)]) {
            if ([event dateStart] == nil ||
                ([calendar component:NSCalendarUnitMonth fromDate:[event dateStart]] == 12 && [calendar component:NSCalendarUnitDay fromDate:[event dateStart]] == 31)) {
                [weeklessEvents addObject:event];
            } else {
                if (weekStart == nil) {
                    int diffFromThurs = ([calendar component:NSCalendarUnitWeekday fromDate:[event dateStart]] - 4) % 7; // Wednesday is 4
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = -diffFromThurs;
                    
                    weekStart = [calendar dateByAddingComponents:dayComponent toDate:[event dateStart] options:0];
                }
                
                NSDateComponents *weekComponent = [[NSDateComponents alloc] init];
                weekComponent.day = 7;
                
                NSComparisonResult dateCompare = [[event dateStart] compare:[calendar dateByAddingComponents:weekComponent toDate:weekStart options:0]];
                if (dateCompare == NSOrderedDescending || dateCompare == NSOrderedSame) {
                    NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
                    NSArray *weekEvents = [eventData objectForKey:weekLabel];
                    if (groupByType) {
                        [eventData setValue:[self sortedEventDictionaryFromEvents:weekEvents] forKey:weekLabel];
                    } else {
                        [eventData setValue:weekEvents forKey:weekLabel];
                    }
                    
                    currentWeek += 1;                    
                    weekStart = [calendar dateByAddingComponents:weekComponent toDate:weekStart options:0];
                }
                
                NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
                if ([eventData objectForKey:weekLabel]) {
                    NSMutableArray *weekArray = [eventData objectForKey:weekLabel];
                    [weekArray addObject:event];
                } else {
                    [eventData setValue:[[NSMutableArray alloc] initWithObjects:event, nil] forKey:weekLabel];
                }
            }
        } else if (event.eventType == TBAEventTypePreseason) {
            [preseasonEvents addObject:event];
        } else {
            [offseasonEvents addObject:event];
        }
    }
    // Put the last week in
    NSString *weekLabel = [NSString stringWithFormat:@"Week %@", @(currentWeek)];
    NSArray *weekEvents = [eventData objectForKey:weekLabel];
    if (weekEvents && [weekEvents count] > 0) {
        if (groupByType) {
            [eventData setValue:[self sortedEventDictionaryFromEvents:weekEvents] forKey:weekLabel];
        } else {
            [eventData setValue:weekEvents forKey:weekLabel];
        }
    }
    
    if ([preseasonEvents count] > 0) {
        if (groupByType) {
            [eventData insertObject:[self sortedEventDictionaryFromEvents:preseasonEvents]
                             forKey:PreseasonEventsLabel
                            atIndex:0];
        } else {
            [eventData insertObject:preseasonEvents forKey:PreseasonEventsLabel atIndex:0];
        }
    }
    if ([championshipEvents count] > 0) {
        if (groupByType) {
            [eventData setValue:[self sortedEventDictionaryFromEvents:championshipEvents] forKey:CMPEventsLabel];
        } else {
            [eventData setValue:championshipEvents forKey:CMPEventsLabel];
        }
    }
    if ([offseasonEvents count] > 0) {
        if (groupByType) {
            [eventData setValue:[self sortedEventDictionaryFromEvents:offseasonEvents] forKey:OffseasonEventsLabel];
        } else {
            [eventData setValue:offseasonEvents forKey:OffseasonEventsLabel];
        }
    }
    if ([weeklessEvents count] > 0) {
        if (groupByType) {
            [eventData setValue:[self sortedEventDictionaryFromEvents:weeklessEvents] forKey:WeeklessEventsLabel];
        } else {
            [eventData setValue:weeklessEvents forKey:WeeklessEventsLabel];
        }
    }
    
    
    return eventData;
}

+ (OrderedDictionary *)sortedEventDictionaryFromEvents:(NSArray *)events {
    // Preseason < Regionals < Districts (MI, MAR, NE, PNW, IN), CMP Divisions, CMP Finals, Offseason, others
    MutableOrderedDictionary *sortedDictionary = [[MutableOrderedDictionary alloc] init];
    
    for (NSNumber *eventType in @[@(EventTypePreseason), @(EventTypeRegional), @(EventTypeDistrict), @(EventTypeDistrictCMP), @(EventTypeCMPDivision), @(EventTypeCMPFinals), @(EventTypeOffseason), @(EventTypeUnlabeled)]) {
        if ([eventType integerValue] == EventTypeDistrict) {
            // Sort districts
            for (NSString *districtString in [District districtTypes]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventDistrict == %@ AND (NOT eventType == %@)", districtString, @(EventTypeDistrictCMP)];
                NSArray *arr = [events filteredArrayUsingPredicate:predicate];
                
                if (arr && [arr count] > 0) {
                    NSString *districtTypeLabel = [NSString stringWithFormat:@"%@ District Events", districtString];
                    [sortedDictionary setValue:arr forKey:districtTypeLabel];
                }
            }
        } else {
            // Sort non-districts
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType = %@", eventType];
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

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@ AND year == %@", modelEvent.key, @(modelEvent.year)];
    [fetchRequest setPredicate:predicate];
    
    Event *event;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        event = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (Event *e in existingObjs) {
            [context deleteObject:e];
        }
    }
    
    if (event == nil) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
    }
    
    event.key = modelEvent.key;
    event.name = modelEvent.name;
    event.shortName = modelEvent.shortName;
    event.eventCode = modelEvent.eventCode;
    event.eventType = modelEvent.eventType;
    event.eventDistrict = modelEvent.eventDistrictString;
    event.year = modelEvent.year;
    event.location = modelEvent.location;
    event.venueAddress = modelEvent.venueAddress;
    event.website = modelEvent.website;
    event.facebookEid = modelEvent.facebookEid;
    event.official = modelEvent.official;
    event.startDate = [modelEvent.startDate timeIntervalSince1970];
    event.endDate = [modelEvent.endDate timeIntervalSince1970];
    
    /*
    event.webcasts = [NSSet setWithArray:[EventWebcast insertEventWebcastsWithModelEventWebcasts:modelEvent.webcast
                                                                                        forEvent:event
                                                                          inManagedObjectContext:context]];

    event.alliances = [NSSet setWithArray:[EventAlliance insertEventAlliancesWithModelEventAlliances:modelEvent.alliances
                                                                                            forEvent:event
                                                                              inManagedObjectContext:context]];
    */

    return event;
}

+ (NSArray *)insertEventsWithModelEvents:(NSArray *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAEvent *event in modelEvents) {
        [arr addObject:[self insertEventWithModelEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
