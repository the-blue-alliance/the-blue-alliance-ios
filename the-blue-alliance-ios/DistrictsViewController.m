//
//  DistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictsViewController.h"

#import "OrderedDictionary.h"
//#import "Event.h"
#import "District.h"
#import "District+Fetch.h"
#import "TBAKit.h"
#import "DistrictViewController.h"

static NSString *const DistrictsCellIdentifier  = @"DistrictsCell";
static NSString *const DistrictsListSegue       = @"DistrictsListSegue";

@interface DistrictsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *districts;

@end


@implementation DistrictsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startYear = 2009;
    
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
        });
    };
    
    [self fetchDistricts];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}

#pragma mark - Data Methods

- (void)fetchDistricts {
    self.districts = nil;
    
    __weak typeof(self) weakSelf = self;
    [District fetchDistrictsForYear:self.currentYear fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *districts, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching districts locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!districts || [districts count] == 0) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.districts = districts;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
}

- (void)refreshData {
    [self fetchDistrictKeysForYear:self.currentYear];
}

- (void)fetchDistrictKeysForYear:(NSInteger)year {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchDistrictsForYear:year withCompletionBlock:^(NSArray *districts, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching districts" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [District insertDistrictsWithDistrictDicts:districts forYear:year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchDistricts];
                [strongSelf.persistenceController save];
            });
        }
    }];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Districts", @(self.currentYear)];
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

    District *distrct = [self.districts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:DistrictsListSegue sender:distrct];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DistrictsListSegue]) {
        District *district = (District *)sender;
        
        DistrictViewController *districtViewController = (DistrictViewController *)segue.destinationViewController;
        districtViewController.persistenceController = self.persistenceController;
        districtViewController.district = district;
    }
}

@end
