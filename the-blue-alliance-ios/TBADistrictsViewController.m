//
//  TBADistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/12/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBADistrictsViewController.h"
#import "District.h"

static NSString *const DistrictsCellIdentifier  = @"DistrictsCell";

@implementation TBADistrictsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.districts) {
        return [self.districts count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DistrictsCellIdentifier forIndexPath:indexPath];
    
    District *district = [self.districts objectAtIndex:indexPath.row];
    cell.textLabel.text = district.name;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.districtSelected) {
        return;
    }
    
    District *distrct = [self.districts objectAtIndex:indexPath.row];
    self.districtSelected(distrct);
}

@end
