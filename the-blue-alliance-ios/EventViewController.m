//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 4/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
/*
#import "HMSegmentedControl.h"
#import <PureLayout/PureLayout.h>


static NSString *const EventDetailCellIdentifier    = @"EventDetailCellIdentifier";
*/

@interface EventViewController () <UITableViewDataSource, UITableViewDelegate>

/*
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
*/
 
@end

@implementation EventViewController
/*
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.event friendlyNameWithYear:YES];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:EventDetailCellIdentifier];
    
    [self styleInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    for (UIButton *button in self.socialButtons) {
        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForEventKeys:@[@"INFO", @"TEAMS", @"RANKINGS", @"MATCHES", @"ALLIANCES", @"DISTRICT POINTS", @"STATS", @"AWARDS"]];
//    self.eventsCollectionViewController.eventData = self.eventData;
//    [self.eventsCollectionViewController.collectionView reloadData];
}

- (void)updateSegmentedControlForEventKeys:(NSArray *)eventKeys {
    if (!eventKeys || [eventKeys count] == 0) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        return;
    }
    
    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = eventKeys;
        [self.segmentedControl setNeedsDisplay];
        return;
    }
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:eventKeys];
    
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
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventDetailCellIdentifier forIndexPath:indexPath];
    
    NSString *cellLabel = @"";
    switch (indexPath.row) {
        case 0:
            cellLabel = @"Teams";
            break;
        case 1:
            cellLabel = @"Rankings";
            break;
        case 2:
            cellLabel = @"Matches";
            break;
        case 3:
            cellLabel = @"Alliances";
            break;
        case 4:
            cellLabel = @"District Points";
            break;
        case 5:
            cellLabel = @"Stats";
            break;
        case 6:
            cellLabel = @"Awards";
            break;

        default:
            break;
    }
    cell.textLabel.text = cellLabel;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
*/
@end
