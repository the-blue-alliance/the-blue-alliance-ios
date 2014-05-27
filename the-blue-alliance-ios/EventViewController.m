//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAImporter.h"
#import "TeamsTableViewController.h"
#import "EventInfoViewController.h"
#import "MatchResultsTableViewController.h"
#import "RankingsTableViewController.h"

@interface EventViewController () <UIToolbarDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *controllers;

@property (nonatomic, strong) UIToolbar *topToolbar;

@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIScrollView *pageView;

@end

@implementation EventViewController

- (instancetype)initWithEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if(self) {
        self.event = event;
        self.context = context;
    }
    return self;
}

- (void)generatePages
{
    [self.pageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    float width = self.view.width;
    float height = self.view.height - (self.topToolbar.height ? self.topToolbar.height : 44);
    for (int i = 0; i < self.controllers.count; i++) {
        UIViewController *controller = self.controllers[i];
        [self addChildViewController:controller];
        
        UIView *view = controller.view;
        view.width = width;
        view.height = height;
        view.origin = CGPointMake(i * width, 0);
        
        [self.pageView addSubview:view];
    }
    
    self.pageView.contentSize = CGSizeMake(self.controllers.count * width, height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.event.short_name;
    self.navigationController.navigationBar.topItem.title = @"";
    
    // Create segmented control top
    self.topToolbar = [[UIToolbar alloc] initForAutoLayout];
    [self.view addSubview:self.topToolbar];
    [self.topToolbar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.topToolbar autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.topToolbar autoSetDimension:ALDimensionHeight toSize:44];
    [self.topToolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.topToolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    self.topToolbar.delegate = self;
    self.topToolbar.translucent = YES;
    self.topToolbar.tintColor = [UIColor TBANavigationBarColor];
    
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"Info", @"Teams", @"Results", @"Rankings"]];
    self.segment.selectedSegmentIndex = 0;
    [self.segment addTarget:self action:@selector(segmentPressed:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segment];
    self.topToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      segmentItem,
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    
    self.pageView = [[UIScrollView alloc] initForAutoLayout];
    [self.view addSubview:self.pageView];
    [self.pageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.pageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.topToolbar];
    self.pageView.pagingEnabled = YES;
    self.pageView.showsHorizontalScrollIndicator = NO;
    self.pageView.showsVerticalScrollIndicator = NO;
    self.pageView.delegate = self;
    
    // Create the different view controllers for the pages
    EventInfoViewController *eivc = [[EventInfoViewController alloc] init];
    eivc.event = self.event;
    
    TeamsTableViewController *tvc = [[TeamsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tvc.eventFilter = self.event;
    tvc.context = self.context;
    tvc.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    MatchResultsTableViewController *mrvc = [[MatchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    RankingsTableViewController *rvc = [[RankingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    self.controllers = @[eivc, tvc, mrvc, rvc];
    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.context];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self generatePages];
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.segment.selectedSegmentIndex = roundf(scrollView.contentOffset.x / scrollView.width);
}


- (void)segmentPressed:(UISegmentedControl *)segment
{
    float xOffset = self.pageView.width * segment.selectedSegmentIndex;
    [self.pageView setContentOffset:CGPointMake(xOffset, 0) animated:YES];
}


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
 