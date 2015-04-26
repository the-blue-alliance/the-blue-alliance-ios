//
//  DistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictsViewController.h"
#import "OrderedDictionary.h"
#import "Event.h"
#import "District.h"
#import "District+Fetch.h"
#import "TBAApp.h"
#import "TBAKit.h"
#import "TBAImporter.h"


static NSString *const DistrictsCellIdentifier  = @"Districts Cell";


@interface DistrictsViewController ()

@property (nonatomic, strong) OrderedDictionary *districtData;
@property (nonatomic, strong) NSMutableArray *currentRequests;

@end


@implementation DistrictsViewController

#pragma mark - Properities

- (NSMutableArray *)currentRequests {
    if (!_currentRequests) {
        _currentRequests = [[NSMutableArray alloc] init];
    }
    return _currentRequests;
}

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
        
        strongSelf.currentYear = selectedYear;
        strongSelf.navigationItem.title = [NSString stringWithFormat:@"%@ Districts", @(selectedYear)];
        
        [strongSelf cancelRefresh];
        [strongSelf updateRefreshBarButtonItem:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf fetchDistricts];
            [strongSelf updateInterface];
        });
    };
    
    self.startYear = 2009;
    
    [self fetchDistricts];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}

- (void)cancelRefresh {
    if (self.currentRequestIdentifier) {
        [super cancelRefresh];
    } else {
        for (NSNumber *request in self.currentRequests) {
            NSUInteger requestIdentifier = [request unsignedIntegerValue];
            [[TBAKit sharedKit] cancelRequestWithIdentifier:requestIdentifier];
        }
    }
}


#pragma mark - Data Methods

- (OrderedDictionary *)groupDistrictsByType:(NSArray *)districts {
    MutableOrderedDictionary *districtData = [[MutableOrderedDictionary alloc] init];

    for (NSNumber *districtType in [District districtTypes]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_district = %@", districtType];
        NSArray *arr = [districts filteredArrayUsingPredicate:predicate];
        
        if (!arr || [arr count] == 0) {
            continue;
        }
        
        NSString *keyName = [NSString stringWithFormat:@"%@ Districts", [District nameForDistrictType:[districtType integerValue]]];
        [districtData setValue:arr forKey:keyName];
    }
    
    return districtData;
}

- (void)fetchDistricts {
    self.districtData = nil;
    
    NSArray *districts = [District fetchDistrictsForYear:self.currentYear fromContext:[TBAApp managedObjectContext]];
    if (!districts || [districts count] == 0) {
        if (self.refresh) {
            self.refresh();
        }
    } else {
        self.districtData = [self groupDistrictsByType:districts];
    }
}

- (void)refreshData {
    NSInteger year = self.currentYear;

    [self fetchDistrictKeysForYear:year];
}

- (void)fetchDistrictKeysForYear:(NSInteger)year {
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"districts/%@", @(year)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;
        
        if (error) {
            NSLog(@"Error loading events: %@", error.localizedDescription);
        }
        if (objects && [objects isKindOfClass:[NSArray class]] && [objects count] != 0) {
            [self fetchDistrictsForDistricts:objects forYear:year];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateRefreshBarButtonItem:NO];
                self.districtData = nil;
                
                [self updateInterface];
            });
        }
    }];
}

- (void)fetchDistrictsForDistricts:(NSArray *)districts forYear:(NSUInteger)year {
    for (NSDictionary *districtDict in districts) {
        NSString *districtShort = districtDict[@"key"];
        
        __block NSUInteger requestIdentifier;
        requestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"district/%@/%@/events", districtShort, @(year)] callback:^(id objects, NSError *error) {
            [self.currentRequests removeObject:[NSNumber numberWithUnsignedInteger:requestIdentifier]];
            
            if (error) {
                NSLog(@"Error loading events: %@", error.localizedDescription);
            }
            if (!error && [objects isKindOfClass:[NSArray class]]) {
                [TBAImporter importEvents:objects];
            }
            if ([self.currentRequests count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateRefreshBarButtonItem:NO];
                    
                    [self fetchDistricts];
                    [self updateInterface];
                });
            }
        }];
        [self.currentRequests addObject:[NSNumber numberWithUnsignedInteger:requestIdentifier]];
    }
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Districts", @(self.currentYear)];
    [self updateInterface];
}

- (void)updateInterface {
    [self.tableView reloadData];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.districtData) {
        return [[self.districtData allKeys] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DistrictsCellIdentifier forIndexPath:indexPath];
    
    NSString *key = [self.districtData keyAtIndex:indexPath.row];
    NSArray *events = [self.districtData objectForKey:key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Events", [events count]];
    
    return cell;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
