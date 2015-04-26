//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "TeamsCollectionViewController.h"
#import "OrderedDictionary.h"
#import "TBAApp.h"
#import "TBAKit.h"
#import "TBAImporter.h"
#import "HMSegmentedControl.h"
#import "TeamsCollectionViewController.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>


@interface TeamsViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) OrderedDictionary *teamData;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) TeamsCollectionViewController *teamsCollectionViewController;

@end


@implementation TeamsViewController

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
    
    [self fetchTeams];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}


#pragma mark - Data Methods

- (OrderedDictionary *)groupTeams:(NSArray *)teams {
    MutableOrderedDictionary *mutableTeams = [[MutableOrderedDictionary alloc] init];

    for (Team *team in teams) {
        if ([[mutableTeams allKeys] containsObject:team.grouping_text]) {
            NSMutableArray *arr = [mutableTeams objectForKey:team.grouping_text];
            [arr addObject:team];
            
            [mutableTeams setValue:arr forKey:team.grouping_text];
        } else {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:team, nil];
            [mutableTeams setValue:arr forKey:team.grouping_text];
        }
    }

    return mutableTeams;
}

- (void)fetchTeams {
    self.teamData = nil;
    
    NSArray *teams = [Team fetchAllTeamsFromContext:[TBAApp managedObjectContext]];
    if (!teams || [teams count] == 0) {
        if (self.refresh) {
            self.refresh();
        }
    } else {
        self.teamData = [self groupTeams:teams];
    }
}

- (void)getTeamsForPage:(int)page {
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"teams/%@", @(page)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;
        
        if (error) {
            NSLog(@"Error loading teams: %@", error.localizedDescription);
        }
        if (!error && [objects isKindOfClass:[NSArray class]] && [objects count] > 0) {
            [TBAImporter importTeams:objects];
        }

        if ([objects isKindOfClass:[NSArray class]]) {
            if ([objects count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateRefreshBarButtonItem:NO];

                    [self fetchTeams];
                    [self updateInterface];
                });
            } else {
                [self getTeamsForPage:page + 1];
            }
        }
    }];
}

- (void)refreshData {
    [self getTeamsForPage:0];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForTeamKeys:self.teamData.allKeys];
    self.teamsCollectionViewController.teams = self.teamData;
    [self.teamsCollectionViewController.collectionView reloadData];
}

- (void)updateSegmentedControlForTeamKeys:(NSArray *)teamKeys {
    if (!teamKeys || [teamKeys count] == 0) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        return;
    }
    
    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = teamKeys;
        [self.segmentedControl setNeedsDisplay];
        return;
    }
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:teamKeys];
    
    self.segmentedControl.frame = self.segmentedControlView.frame;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor TBANavigationBarColor];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlView addSubview:self.segmentedControl];
    
    [self.segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self.teamsCollectionViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:segmentedControl.selectedSegmentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


#pragma mark - Collection View Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.teamsCollectionViewController.collectionView.frame.size;
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.teamsCollectionViewController.collectionView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TeamsCollectionViewControllerEmbedSegue"]) {
        TeamsCollectionViewController *teamsCollectionViewController = segue.destinationViewController;
        teamsCollectionViewController.collectionView.delegate = self;
        self.teamsCollectionViewController = teamsCollectionViewController;
    }
}


@end
