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

@interface EventViewController () <UIToolbarDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *controllers;

@property (nonatomic, strong) UIToolbar *topToolbar;

@property (nonatomic, strong) UISegmentedControl *segment;

@property (nonatomic, strong) UIPageViewController *pageController;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.event.friendlyName;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navBar setShadowImage:[[UIImage alloc] init]];
    

    
    // Create segmented control top
    self.topToolbar = [[UIToolbar alloc] initForAutoLayout];
    [self.view addSubview:self.topToolbar];
    [self.topToolbar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.topToolbar autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.topToolbar autoSetDimension:ALDimensionHeight toSize:44];
    [self.topToolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.topToolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    self.topToolbar.delegate = self;
    self.topToolbar.translucent = NO;
    self.topToolbar.barTintColor = [UIColor TBANavigationBarColor];
    
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"Info", @"Teams", @"Results", @"Rankings"]];
    self.segment.selectedSegmentIndex = 0;
    [self.segment addTarget:self action:@selector(segmentPressed:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segment];
    self.topToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      segmentItem,
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    
    // Create the different view controllers for the pages
    EventInfoViewController *eivc = [[EventInfoViewController alloc] init];
    eivc.event = self.event;
    
    TeamsTableViewController *tvc = [[TeamsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tvc.eventFilter = self.event;
    tvc.disableSections = YES;
    tvc.context = self.context;
    
    MatchResultsTableViewController *mrvc = [[MatchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    mrvc.context = self.context;
    mrvc.event = self.event;
    
    RankingsTableViewController *rvc = [[RankingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    rvc.context = self.context;
    rvc.event = self.event;
    
    
    self.controllers = @[eivc, tvc, mrvc, rvc];
    
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    self.pageController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageController.view.backgroundColor = [UIColor whiteColor];
    [self.pageController.view.subviews[0] setScrollEnabled:NO];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.controllers firstObject]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [self.pageController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.pageController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.topToolbar];
    
    
    
    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.context];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)orientationChanged:(NSNotification *)notification
{
    // Set the page controller's view controller to what it already is
    // This forces it to resize the view controller
    UIViewController *currentController = [self.pageController.viewControllers firstObject];
    [self.pageController setViewControllers:@[currentController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = [self.controllers indexOfObject:viewController];
    if(index == self.controllers.count - 1) {
        return nil;
    } else {
        return self.controllers[index + 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self.controllers indexOfObject:viewController];
    if(index == 0) {
        return nil;
    } else {
        return self.controllers[index - 1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *controller = [self.pageController.viewControllers firstObject];
    self.segment.selectedSegmentIndex = [self.controllers indexOfObject:controller];
}
- (void)segmentPressed:(UISegmentedControl *)segment
{
    int currentIndex = [self.controllers indexOfObject:[self.pageController.viewControllers firstObject]];
    int newIndex = segment.selectedSegmentIndex;

    UIPageViewControllerNavigationDirection direction = newIndex >= currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    UIViewController *controller = self.controllers[newIndex];

    @try {
        [self.pageController setViewControllers:@[controller] direction:direction animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"COULD NOT CHANGE VIEW CONTROLLERS!");
    }

}


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
 