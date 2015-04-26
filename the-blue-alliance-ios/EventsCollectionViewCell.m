//
//  EventsCollectionViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/23/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventsCollectionViewCell.h"
#import "EventsViewController.h"
#import "OrderedDictionary.h"
#import "EventTableViewCell.h"
#import "Event.h"


static NSString *const EventCellReuseIdentifier = @"Event Cell";


@implementation EventsCollectionViewCell

#pragma mark - Initilization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.backgroundView.backgroundColor = [UIColor TBANavigationBarColor];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:12.0f];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *eventKey = [self.weekData.allKeys objectAtIndex:section];
    return eventKey;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.weekData) {
        return 0;
    }
    return [self.weekData.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.weekData) {
        return 0;
    }
    
    NSString *eventKey = [self.weekData.allKeys objectAtIndex:section];
    NSArray *eventArray = [self.weekData objectForKey:eventKey];
    
    return [eventArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellReuseIdentifier forIndexPath:indexPath];
    
    Event *event = [self eventForIndexPath:indexPath];
    
    cell.nameLabel.text = [event friendlyNameWithYear:NO];
    cell.locationLabel.text = event.location;
    
    NSString *dateText;
    NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
    [endDateFormatter setDateFormat:@"MMM dd, y"];
    
    if (event.start_date.year == event.end_date.year) {
        NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
        [startDateFormatter setDateFormat:@"MMM dd"];
        
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [startDateFormatter stringFromDate:event.start_date],
                    [endDateFormatter stringFromDate:event.end_date]];
        
    } else {
        dateText = [NSString stringWithFormat:@"%@ to %@",
                    [endDateFormatter stringFromDate:event.start_date],
                    [endDateFormatter stringFromDate:event.end_date]];
    }
    cell.datesLabel.text = dateText;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Event *event = [self eventForIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventTapped object:event];
}


#pragma mark - Private Methods

- (Event *)eventForIndexPath:(NSIndexPath *)indexPath {
    NSString *eventKey = [self.weekData.allKeys objectAtIndex:indexPath.section];
    NSArray *eventArray = [self.weekData objectForKey:eventKey];
    
    return [eventArray objectAtIndex:indexPath.row];
}

@end
