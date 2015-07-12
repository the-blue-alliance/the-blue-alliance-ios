//
//  DistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictsViewController.h"
#import "TBADistrictsViewController.h"
#import "District.h"
#import "District+Fetch.h"
#import "TBAKit.h"
#import "DistrictViewController.h"

static NSString *const DistrictsViewControllerEmbed = @"DistrictsViewControllerEmbed";
static NSString *const DistrictViewControllerSegue  = @"DistrictViewControllerSegue";

@interface DistrictsViewController ()

@property (nonatomic, strong) TBADistrictsViewController *districtsViewController;

@end


@implementation DistrictsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.districtsViewController hideNoDataView];
        [strongSelf refreshDistricts];
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf cancelRefresh];
        
        [strongSelf.districtsViewController hideNoDataView];
        [strongSelf removeDistricts];
        
        strongSelf.currentYear = selectedYear;
        [strongSelf fetchDistrictsAndRefresh:YES];
    };
    
    [self configureYears];
    [self fetchDistrictsAndRefresh:YES];
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = @"Districts";
}

#pragma mark - Data Methods

- (void)configureYears {
    // TODO: Look for year + 1 as well
    
    NSInteger year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:2009 endYear:year];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
    }
}

#pragma mark - Data Methods

- (void)removeDistricts {
    self.districtsViewController.districts = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.districtsViewController.tableView reloadData];
    });
}

- (void)fetchDistrictsAndRefresh:(BOOL)refresh {
    if (self.currentYear == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [District fetchDistrictsForYear:self.currentYear fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *districts, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString *errorMessage = @"Unable to fetch districts locally";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.districtsViewController.districts) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.districtsViewController showNoDataViewWithText:errorMessage];
                }
            });
            return;
        }
        
        if ([districts count] == 0) {
            if (refresh && strongSelf.refresh) {
                strongSelf.refresh();
            } else {
                [self removeDistricts];
            }
        } else {
            strongSelf.districtsViewController.districts = districts;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.districtsViewController.tableView reloadData];
            });
        }
    }];
}

- (void)refreshDistricts {
    if (self.currentYear == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.districtsViewController showNoDataViewWithText:@"No year selected"];
        });
        return;
    }
    __block NSUInteger year = self.currentYear;
    
    [self updateRefreshBarButtonItem:YES];
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchDistrictsForYear:year withCompletionBlock:^(NSArray *districts, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            NSString *errorMessage = @"Unable to load districts";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.districtsViewController.districts) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.districtsViewController showNoDataViewWithText:errorMessage];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [District insertDistrictsWithDistrictDicts:districts forYear:year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchDistrictsAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DistrictsViewControllerEmbed]) {
        self.districtsViewController = (TBADistrictsViewController *)segue.destinationViewController;
        
        __weak typeof(self) weakSelf = self;
        self.districtsViewController.districtSelected = ^(District *district) {
            [weakSelf performSegueWithIdentifier:DistrictViewControllerSegue sender:district];
        };
    } else if ([segue.identifier isEqualToString:DistrictViewControllerSegue]) {
        District *district = (District *)sender;
        
        DistrictViewController *districtViewController = (DistrictViewController *)segue.destinationViewController;
        districtViewController.persistenceController = self.persistenceController;
        districtViewController.district = district;
    }
}

@end
