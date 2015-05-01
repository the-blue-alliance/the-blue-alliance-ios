//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "OrderedDictionary.h"
#import "TBAApp.h"
#import "TBAKit.h"
#import "TBAImporter.h"
#import "HMSegmentedControl.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TeamTableViewCell.h"


static NSString *const TeamCellReuseIdentifier = @"Team Cell";


@interface TeamsViewController ()

@property (nonatomic, strong) IBOutlet UIView *segmentedControlView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewLeadingConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewTrailingConstraint;

// Ordered dict of "Groupings" (1-999, 1000-1999, 2000-2999, ...)
// Groupings have arrays of teams [1, 4, 5, 6, 7, ...]
@property (nonatomic, strong) OrderedDictionary *teamData;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger currentSegmentIndex;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:self.leftSwipeGestureRecognizer];

    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForTeamKeys:self.teamData.allKeys];
    [self.tableView reloadData];
}

- (void)swipedRight:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    [self animateToIndex:self.currentSegmentIndex - 1];
}

- (void)swipedLeft:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    [self animateToIndex:self.currentSegmentIndex + 1];
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
    [self animateToIndex:segmentedControl.selectedSegmentIndex];
}

- (void)animateToIndex:(NSInteger)index {
    if (index == self.currentSegmentIndex || index < 0 || index >= [self.teamData.allKeys count]) {
        return;
    }
    
    ALAttribute firstAttr;
    ALAttribute secondAttr;
    if (index > self.currentSegmentIndex) {
        firstAttr = ALAttributeLeading;
        secondAttr = ALAttributeTrailing;
    } else {
        firstAttr = ALAttributeTrailing;
        secondAttr = ALAttributeLeading;
    }
    
    UIView *oldTableView = [self.tableView snapshotViewAfterScreenUpdates:NO];
    oldTableView.frame = self.tableView.frame;
    [self.view addSubview:oldTableView];
    
    self.currentSegmentIndex = index;
    [self.tableView reloadData];
    
    NSLayoutConstraint *oldTableViewCenterVerticalConstraint = [oldTableView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    [oldTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.segmentedControlView];
    [oldTableView autoSetDimension:ALDimensionHeight toSize:CGRectGetHeight(oldTableView.frame)];
    [oldTableView autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(oldTableView.frame)];
    
    NSLayoutConstraint *tableViewWidthConstraint = [self.tableView autoSetDimension:ALDimensionWidth toSize:CGRectGetWidth(self.tableView.frame)];
    [self.view removeConstraints:@[self.tableViewLeadingConstraint, self.tableViewTrailingConstraint]];
    NSLayoutConstraint *tableViewCenterVerticalConstrait = [self.tableView autoConstrainAttribute:firstAttr toAttribute:secondAttr ofView:self.view];
    
    [self.view layoutIfNeeded];
    
    [self.view removeConstraint:oldTableViewCenterVerticalConstraint];
    [oldTableView autoConstrainAttribute:secondAttr toAttribute:firstAttr ofView:self.view];
    
    [self.view removeConstraint:tableViewCenterVerticalConstrait];
    tableViewCenterVerticalConstrait = [self.tableView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    
    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
    
    // Same duration that our sliding tabs are moving
    [UIView animateWithDuration:0.15f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [oldTableView removeFromSuperview];
        [self.view removeConstraints:@[tableViewWidthConstraint, tableViewCenterVerticalConstrait]];
        [self.view addConstraints:@[self.tableViewLeadingConstraint, self.tableViewTrailingConstraint]];
    }];
}


#pragma mark - Data Methods

- (NSArray *)teamArrayForIndex:(NSInteger)index {
    NSArray *teamKeys = [self.teamData allKeys];
    if (!teamKeys || index >= [teamKeys count]) {
        return nil;
    }
    NSString *teamKey = [teamKeys objectAtIndex:index];
    
    return [self.teamData objectForKey:teamKey];
}

- (Team *)teamForSegmentIndex:(NSInteger)sectionIndex forIndexPath:(NSIndexPath *)indexPath {
    NSArray *teamArray = [self teamArrayForIndex:sectionIndex];
    Team *team = [teamArray objectAtIndex:indexPath.row];
    
    return team;
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.teamData) {
        // TODO: Show no data screen
        return 0;
    }
    NSArray *teamArray = [self teamArrayForIndex:self.currentSegmentIndex];
    if (!teamArray) {
        // TODO: Show no data screen
        return 0;
    }
    return [teamArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
    
    Team *team = [self teamForSegmentIndex:self.currentSegmentIndex forIndexPath:indexPath];

    cell.numberLabel.text = [team.team_number stringValue];
    cell.nameLabel.text = team.nickname;
    cell.locationLabel.text = team.location;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Team *team = [self teamForSegmentIndex:self.currentSegmentIndex forIndexPath:indexPath];
    NSLog(@"Selected team: %@", team.team_number);
}


#pragma mark - Navigation

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TeamsCollectionViewControllerEmbedSegue"]) {
        TeamsCollectionViewController *teamsCollectionViewController = segue.destinationViewController;
        teamsCollectionViewController.collectionView.delegate = self;
        self.teamsCollectionViewController = teamsCollectionViewController;
    }
}
*/

@end
