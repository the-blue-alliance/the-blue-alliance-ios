//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 4/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAInfoViewController.h"

@interface EventViewController ()

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@end

@implementation EventViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.startYear = 2009;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            //            [strongSelf refreshData];
        }
    };
    /*
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //        strongSelf.currentYear = selectedYear;
        
        [strongSelf cancelRefresh];
        [strongSelf updateRefreshBarButtonItem:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [strongSelf fetchDistricts];
        });
    };
    */
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
//    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
//    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", @(self.team.teamNumber)];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.event = self.event;
    }
}

@end
