//
//  DistrictEventsTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictEventsViewController.h"
#import "OrderedDictionary.h"
#import "TBAEventTableViewCell.h"
#import "District.h"
#import "District+Fetch.h"
#import "Event.h"
#import "Event+Fetch.h"
#import "TBAKit.h"


static NSString *const EventCellReuseIdentifier = @"EventCell";


@interface DistrictEventsViewController () <UITableViewDelegate, UITableViewDataSource>

// Key is week string ("Week 1", "Week 2", "Week 3", ...)
// Value is array of events for that week
@property (nonatomic, strong) OrderedDictionary *districtData;
 
@end

@implementation DistrictEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self fetchDistricts];
    [self styleInterface];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Data Methods

- (void)fetchDistricts {
    self.districtData = nil;
    
    __weak typeof(self) weakSelf = self;
    [District fetchEventsForDistrict:self.district fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch district events locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!events || [events count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.districtData = [Event groupEventsByWeek:events];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}

- (OrderedDictionary *)weekDictionaryForIndex:(NSInteger)index {
    NSArray *weekKeys = [self.districtData allKeys];
    if (!weekKeys || index >= [weekKeys count]) {
        return nil;
    }
    NSString *weekKey = [weekKeys objectAtIndex:index];
    
    return [self.districtData objectForKey:weekKey];
}

- (NSArray *)districtsForIndex:(NSInteger)index {
    NSDictionary *weekDictionary = [self weekDictionaryForIndex:index];
    if (!weekDictionary) {
        return nil;
    }
    NSString *districtKey = [weekDictionary.allKeys firstObject];
    
    return [weekDictionary objectForKey:districtKey];
}

- (Event *)districtForIndexPath:(NSIndexPath *)indexPath {
    NSArray *districts = [self districtsForIndex:indexPath.section];
    if (!districts) {
        return nil;
    }
    return [districts objectAtIndex:indexPath.row];
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
    NSString *weekKey = [self.districtData.allKeys objectAtIndex:section];
    return weekKey;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.districtData) {
        return 0;
    }
    return [self.districtData.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *districts = [self districtsForIndex:section];
    if (!districts) {
        return 0;
    }
    return [districts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellReuseIdentifier forIndexPath:indexPath];
    
    Event *event = [self districtForIndexPath:indexPath];
    cell.event = event;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
