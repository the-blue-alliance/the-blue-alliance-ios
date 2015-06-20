//
//  TeamViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/7/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamViewController.h"
#import "TBAEventsViewController.h"
#import "TBAInfoViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Media.h"

typedef NS_ENUM(NSInteger, TBATeamDataType) {
    TBATeamDataTypeInfo = 0,
    TBATeamDataTypeEvents
};

@interface TeamViewController ()

@property (nonatomic, weak) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) TBAInfoViewController *infoViewController;
@property (nonatomic, weak) IBOutlet UIView *infoView;

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;

@end

@implementation TeamViewController

// Should also fetch years participated

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
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
//        strongSelf.currentYear = selectedYear;
        
        [strongSelf cancelRefresh];
        [strongSelf updateRefreshBarButtonItem:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [strongSelf fetchDistricts];
        });
    };
    
    [self refreshMedia];
    [self styleInterface];
}

#pragma mark - Data Methods

- (void)refreshTeamInfo {
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchTeamForTeamKey:self.team.key withCompletionBlock:^(TBATeam *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching team info" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Team insertTeamWithModelTeam:team inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchTeam];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

- (void)fetchTeam {
    __weak typeof(self) weakSelf = self;
    [Team fetchTeamForKey:self.team.key fromContext:self.persistenceController.managedObjectContext checkUpstream:NO withCompletionBlock:^(Team *team, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAlertWithTitle:@"Unable to fetch team locally" andMessage:error.localizedDescription];
            return;
        }
        
        if (!team) {
            if (strongSelf.refresh) {
                strongSelf.refresh();
            }
        } else {
            strongSelf.team = team;
            strongSelf.infoViewController.team = team;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf updateInterface];
            });
        }
    }];
}

- (void)refreshMedia {
    __block NSInteger year = self.currentYear;
    
    __weak typeof(self) weakSelf = self;
    self.currentRequestIdentifier = [[TBAKit sharedKit] fetchMediaForTeamKey:self.team.key andYear:self.currentYear withCompletionBlock:^(NSArray *media, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.currentRequestIdentifier = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateRefreshBarButtonItem:NO];
        });
        
        if (error) {
            [strongSelf showAlertWithTitle:@"Error fetching media" andMessage:error.localizedDescription];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Media insertMediasWithModelMedias:media forTeam:self.team andYear:year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf updateInterface];
                [strongSelf.persistenceController save];
            });
        }
    }];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = [NSString stringWithFormat:@"Team %@", self.team.teamNumber];
}

- (void)updateInterface {
    [self.infoViewController.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoViewControllerEmbed"]) {
        self.infoViewController = segue.destinationViewController;
        self.infoViewController.team = self.team;
    }
}

@end
