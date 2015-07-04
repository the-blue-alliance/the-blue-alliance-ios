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

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf updateRefreshBarButtonItem:YES];
        [strongSelf refreshData];
    };
    
    self.requestsFinished = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf updateRefreshBarButtonItem:NO];
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentYear = selectedYear;
        [strongSelf cancelRefresh];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf fetchDistricts];
        });
    };
    
    [self configureYears];
    [self fetchDistricts];
    [self styleInterface];
}

#pragma mark - Data Methods

- (void)configureYears {
    NSInteger year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:2009 endYear:year];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
    }
}

#pragma mark - Data Methods

- (void)fetchDistricts {
    if (!self.refreshing) {
        self.districts = nil;
        [self.tableView reloadData];
    }
    
    __weak typeof(self) weakSelf = self;
    [District fetchDistrictsForYear:self.currentYear fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *districts, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching districts locally" andMessage:error.localizedDescription];
            return;
        }
        
        if ([districts count] == 0 && !self.refreshing) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.districts = districts;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
        self.refreshing = NO;
    }];
}

- (void)refreshData {
    [self fetchDistrictKeysForYear:self.currentYear];
}

- (void)fetchDistrictKeysForYear:(NSInteger)year {
    self.refreshing = YES;
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchDistrictsForYear:year withCompletionBlock:^(NSArray *districts, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching districts" andMessage:error.localizedDescription];
            self.refreshing = NO;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [District insertDistrictsWithDistrictDicts:districts forYear:year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchDistricts];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"Districts";
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
