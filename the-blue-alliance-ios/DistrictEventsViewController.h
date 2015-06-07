//
//  DistrictEventsTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/2/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"
#import "District.h"

@interface DistrictEventsViewController : TBAViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) District *district;
@property (nonatomic, copy) void (^refresh)();

- (void)fetchDistricts;

@end
