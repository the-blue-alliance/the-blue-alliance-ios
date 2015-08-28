//
//  TBAEventsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAEventsViewController.h"
#import "TBAEventTableViewCell.h"
#import "OrderedDictionary.h"
#import "Event.h"
#import "UIColor+TBAColors.h"

static NSString *const EventCellReuseIdentifier = @"EventCell";

@implementation TBAEventsViewController

#pragma mark - Data Methods

- (NSArray *)eventsForIndex:(NSInteger)index forEventDictionary:(OrderedDictionary *)eventDictionary {
    if (!eventDictionary || !eventDictionary.allKeys || index >= [eventDictionary.allKeys count]) {
        return nil;
    }
    
    NSString *eventTypeKey = [eventDictionary.allKeys objectAtIndex:index];
    return [eventDictionary objectForKey:eventTypeKey];
}

- (Event *)eventForIndexPath:(NSIndexPath *)indexPath {
    NSArray *eventsArray = [self eventsForIndex:indexPath.section forEventDictionary:self.events];
    Event *event = [eventsArray objectAtIndex:indexPath.row];
    
    return event;
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.backgroundView.backgroundColor = [UIColor TBANavigationBarColor];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:12.0f];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (!self.events) {
        title = @"";
    } else {
        title = [self.events.allKeys objectAtIndex:section];
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count;
    if (!self.events) {
        // TODO: Show a no data screen?
        count = 0;
    } else {
        count = [self.events.allKeys count];
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count;
    if (!self.events) {
        count = 0;
    } else {
        NSArray *events = [self eventsForIndex:section forEventDictionary:self.events];
        count = [events count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAEventTableViewCell *cell = (TBAEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:EventCellReuseIdentifier forIndexPath:indexPath];
    
    Event *event = [self eventForIndexPath:indexPath];
    cell.event = event;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.eventSelected) {
        return;
    }
    
    Event *event = [self eventForIndexPath:indexPath];
    self.eventSelected(event);
}

@end
