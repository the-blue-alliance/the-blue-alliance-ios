//
//  TBAPaginatedViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TBAPaginatedViewController.h"

@interface TBAPaginatedViewController () <UIToolbarDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIToolbar *topToolbar;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation TBAPaginatedViewController

- (NSArray *)viewControllers
{
    if(!_viewControllers) {
        _viewControllers = [self loadViewControllers];
    }
    return _viewControllers;
}

- (NSArray *)loadViewControllers
{
    return @[];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:self.viewControllers.count];
    for (UIViewController *controller in self.viewControllers) {
        [titles addObject:controller.title.length ? controller.title : @"NO TITLE"];
    }
    
    self.segment = [[UISegmentedControl alloc] initWithItems:titles];
    self.segment.selectedSegmentIndex = 0;
    [self.segment addTarget:self action:@selector(segmentPressed:) forControlEvents:UIControlEventValueChanged];
    self.segment.apportionsSegmentWidthsByContent = YES;
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segment];
    self.topToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              segmentItem,
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    self.pageController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageController.view.backgroundColor = [UIColor whiteColor];
    [self.pageController.view.subviews[0] setScrollEnabled:NO];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.viewControllers firstObject]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [self.pageController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.pageController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.topToolbar];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
    int index = [self.viewControllers indexOfObject:viewController];
    if(index == self.viewControllers.count - 1) {
        return nil;
    } else {
        return self.viewControllers[index + 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self.viewControllers indexOfObject:viewController];
    if(index == 0) {
        return nil;
    } else {
        return self.viewControllers[index - 1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *controller = [self.pageController.viewControllers firstObject];
    self.segment.selectedSegmentIndex = [self.viewControllers indexOfObject:controller];
}
- (void)segmentPressed:(UISegmentedControl *)segment
{
    int currentIndex = [self.viewControllers indexOfObject:[self.pageController.viewControllers firstObject]];
    int newIndex = segment.selectedSegmentIndex;
    
    UIPageViewControllerNavigationDirection direction = newIndex >= currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    UIViewController *viewControllers = self.viewControllers[newIndex];
    
    @try {
        [self.pageController setViewControllers:@[viewControllers] direction:direction animated:YES completion:nil];
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
