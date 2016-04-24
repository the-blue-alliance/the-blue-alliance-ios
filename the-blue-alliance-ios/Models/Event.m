//
//  Event.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "Event.h"
#import "EventAlliance.h"
#import "EventPoints.h"
#import "EventRanking.h"
#import "EventWebcast.h"
#import "Match.h"
#import "Team.h"
#import "District.h"

@implementation Event

@dynamic endDate;
@dynamic eventCode;
@dynamic eventDistrict;
@dynamic eventType;
@dynamic facebookEid;
@dynamic hybridType;
@dynamic key;
@dynamic location;
@dynamic name;
@dynamic official;
@dynamic shortName;
@dynamic startDate;
@dynamic venueAddress;
@dynamic website;
@dynamic week;
@dynamic year;
@dynamic eventDistrictString;
@dynamic eventTypeString;
@dynamic alliances;
@dynamic matches;
@dynamic points;
@dynamic rankings;
@dynamic teams;
@dynamic webcasts;
@dynamic awards;

+ (nonnull NSString *)stringForEventOrder:(NSNumber *)order {
    NSString *orderString;
    NSInteger orderInteger = order.integerValue;
    switch (orderInteger) {
        case EventOrderPreseason:
            orderString = @"Preseason";
            break;
        case EventOrderChampionship:
            orderString = @"Championship";
            break;
        case EventOrderOffseason:
            orderString = @"Offseason";
            break;
        case EventOrderUnlabeled:
            orderString = @"Other";
            break;
        default:
            orderString = [NSString stringWithFormat:@"Week %@", order];
            break;
    }
    return orderString;
}

- (NSString *)friendlyNameWithYear:(BOOL)withYear {
    NSString *nameString;
    if (withYear) {
        nameString = [NSString stringWithFormat:@"%@ %@", [self.year stringValue], self.shortName ? self.shortName : self.name];
    } else {
        nameString = [NSString stringWithFormat:@"%@", self.shortName ? self.shortName : self.name];
    }
    
    NSString *typeSuffix = @"";
    switch ([self.eventType integerValue]) {
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
    if (!self.startDate || !self.endDate) {
        return nil;
    }

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
    [endDateFormatter setDateFormat:@"MMM dd, y"];
    
    NSString *dateText;
    if ([calendar component:NSCalendarUnitYear fromDate:self.startDate] == [calendar component:NSCalendarUnitYear fromDate:self.endDate]) {
        NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
        [startDateFormatter setDateFormat:@"MMM dd"];
        
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [startDateFormatter stringFromDate:self.startDate],
                    [startDateFormatter stringFromDate:self.endDate]];
        
    } else {
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [endDateFormatter stringFromDate:self.startDate],
                    [endDateFormatter stringFromDate:self.endDate]];
    }
    
    return dateText;
}

#pragma mark - Class Methods

+ (void)addEventOrder:(EventOrder)eventOrder toArray:(NSMutableArray<NSNumber *> *)arr {
    if (![arr containsObject:@(eventOrder)]) {
        [arr addObject:@(eventOrder)];
    }
}

+ (NSArray<NSNumber *> *)groupEventsByWeek:(NSArray<Event *> *)events {
    NSMutableArray<NSNumber *> *eventTypeArray = [[NSMutableArray alloc] init];
    
    float currentWeek = 1;
    NSDate *weekStart;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (Event *event in events) {
        if (event.official &&
            ([event.eventType integerValue] == TBAEventTypeCMPDivision || [event.eventType integerValue] == TBAEventTypeCMPFinals)) {
            [self addEventOrder:EventOrderChampionship toArray:eventTypeArray];
            event.week = @(EventOrderChampionship);
        } else if (event.official && [@[@(EventTypeRegional), @(EventTypeDistrict), @(EventTypeDistrictCMP)] containsObject:event.eventType]) {
            if (event.startDate == nil ||
                ([calendar component:NSCalendarUnitMonth fromDate:event.startDate] == 12 && [calendar component:NSCalendarUnitDay fromDate:event.startDate] == 31)) {
                [self addEventOrder:EventOrderUnlabeled toArray:eventTypeArray];
                event.week = @(EventOrderUnlabeled);
            } else {
                if (weekStart == nil) {
                    int diffFromThurs = ([calendar component:NSCalendarUnitWeekday fromDate:event.startDate] - 4) % 7; // Wednesday is 4
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = -diffFromThurs;
                    
                    weekStart = [calendar dateByAddingComponents:dayComponent toDate:event.startDate options:0];
                }
                
                NSDateComponents *weekComponent = [[NSDateComponents alloc] init];
                weekComponent.day = 7;
                
                NSComparisonResult dateCompare = [event.startDate compare:[calendar dateByAddingComponents:weekComponent toDate:weekStart options:0]];
                if (dateCompare == NSOrderedDescending || dateCompare == NSOrderedSame) {
                    [self addEventOrder:currentWeek toArray:eventTypeArray];
                    event.week = @(currentWeek);
                    
                    currentWeek += 1;
                    weekStart = [calendar dateByAddingComponents:weekComponent toDate:weekStart options:0];
                }
                
                /**
                 * Special cases for 2016:
                 * Week 1 is actually Week 0.5, eveything else is one less
                 * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
                 */
                if (event.year.integerValue == 2016) {
                    if (currentWeek == 1) {
                        [eventTypeArray addObject:@(0.5f)];
                        event.week = @(0.5);
                    } else {
                        [self addEventOrder:currentWeek - 1 toArray:eventTypeArray];
                        event.week = @(currentWeek - 1);
                    }
                } else {
                    [self addEventOrder:currentWeek toArray:eventTypeArray];
                    event.week = @(currentWeek);
                }
            }
        } else if ([event.eventType integerValue] == TBAEventTypePreseason) {
            [self addEventOrder:EventOrderPreseason toArray:eventTypeArray];
            event.week = @(EventOrderPreseason);
        } else {
            [self addEventOrder:EventOrderOffseason toArray:eventTypeArray];
            event.week = @(EventOrderOffseason);
        }
    }
    return eventTypeArray;
}

// Transient property we use to sort events for the event FRC
// Will sort high level events in order
// Preseason < Regionals < Districts (MI, MAR, NE, PNW, IN), CMP Divisions, CMP Finals, Offseason, others
// Will then sub-divide districts in to floats
// ex: Michigan Districts: 1.1, Indiana Districts: 1.5
- (NSNumber *)hybridType {
    if ([self.eventDistrict integerValue] != 0 && [self.eventType integerValue] != EventTypeDistrictCMP) {
        return @([self.eventType unsignedIntegerValue] + ([self.eventDistrict floatValue] / 10.0f));
    } else {
        return self.eventType;
    }
}

// Takes hybridType and makes a string for it (used for section titles)
- (nonnull NSString *)hybridString {
    NSNumber *hybridType = [self hybridType];
    NSString *hybridString = [hybridType stringValue];
    
    NSArray *arr = [hybridString componentsSeparatedByString:@"."];
    if (arr.count == 2) {
        return [NSString stringWithFormat:@"%@ %@", self.eventDistrictString, self.eventTypeString];
    } else {
        return self.eventTypeString;
    }
}

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelEvent.key];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Event *event) {
        event.key = modelEvent.key;
        event.name = modelEvent.name;
        event.shortName = modelEvent.shortName;
        event.eventCode = modelEvent.eventCode;
        event.eventType = @(modelEvent.eventType);
        event.eventTypeString = modelEvent.eventTypeString;
        event.eventDistrict = @(modelEvent.eventDistrict);
        event.eventDistrictString = modelEvent.eventDistrictString;
        event.year = @(modelEvent.year);
        event.location = modelEvent.location;
        event.venueAddress = modelEvent.venueAddress;
        event.website = modelEvent.website;
        event.facebookEid = modelEvent.facebookEid;
        event.official = @(modelEvent.official);
        event.startDate = modelEvent.startDate;
        event.endDate = modelEvent.endDate;
        
        event.webcasts = [NSSet setWithArray:[EventWebcast insertEventWebcastsWithModelEventWebcasts:modelEvent.webcast
                                                                                            forEvent:event
                                                                              inManagedObjectContext:context]];
        
        event.alliances = [NSSet setWithArray:[EventAlliance insertEventAlliancesWithModelEventAlliances:modelEvent.alliances
                                                                                                forEvent:event
                                                                                  inManagedObjectContext:context]];
    }];
}

+ (NSArray<Event *> *)insertEventsWithModelEvents:(NSArray<TBAEvent *> *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAEvent *event in modelEvents) {
        [arr addObject:[self insertEventWithModelEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
