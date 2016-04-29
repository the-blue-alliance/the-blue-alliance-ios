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
#import "DistrictViewController.h"

static NSString *const DistrictsViewControllerEmbed = @"DistrictsViewControllerEmbed";
static NSString *const DistrictViewControllerSegue  = @"DistrictViewControllerSegue";

@interface DistrictsViewController ()

@property (nonatomic, strong) TBADistrictsViewController *districtsViewController;
@property (nonatomic, strong) IBOutlet UIView *districtsView;

@end


@implementation DistrictsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshViewControllers = @[self.districtsViewController];
    self.containerViews = @[self.districtsView];
    
    __weak typeof(self) weakSelf = self;
    self.yearSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf cancelRefreshes];
        
        strongSelf.currentYear = year;
        strongSelf.districtsViewController.year = year;
    };

    [self configureYears];
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = @"Districts";
}

#pragma mark - Data Methods

- (void)configureYears {
    NSNumber *year = [TBASelectYearViewController currentYear];
    self.years = [TBASelectYearViewController yearsBetweenStartYear:2009 endYear:year.integerValue];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
        self.districtsViewController.year = year;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DistrictsViewControllerEmbed]) {
        self.districtsViewController = (TBADistrictsViewController *)segue.destinationViewController;
        self.districtsViewController.year = self.currentYear;
        
        __weak typeof(self) weakSelf = self;
        self.districtsViewController.districtSelected = ^(District *district) {
            [weakSelf performSegueWithIdentifier:DistrictViewControllerSegue sender:district];
        };
    } else if ([segue.identifier isEqualToString:DistrictViewControllerSegue]) {
        District *district = (District *)sender;
        
        DistrictViewController *districtViewController = (DistrictViewController *)segue.destinationViewController;
        districtViewController.district = district;
    }
}

@end
