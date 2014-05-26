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

@property (nonatomic, strong) UISegmentedControl *segment;
@end

@implementation EventViewController

- (instancetype)initWithEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if(self) {
        self.event = event;
        self.context = context;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.event.short_name;
    
    // Create segmented control top
    UIToolbar *toolbar = [[UIToolbar alloc] initForAutoLayout];
    [self.view addSubview:toolbar];
    [toolbar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [toolbar autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [toolbar autoSetDimension:ALDimensionHeight toSize:44];
    [toolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [toolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    toolbar.delegate = self;
    toolbar.translucent = YES;
    toolbar.tintColor = [UIColor TBANavigationBarColor];
    
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"Info", @"Teams", @"Results", @"Rankings"]];
    self.segment.selectedSegmentIndex = 0;
    [self.segment addTarget:self action:@selector(segmentPressed:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segment];
    toolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      segmentItem,
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    EventInfoViewController *eivc = [[EventInfoViewController alloc] init];
    
    TeamsTableViewController *tvc = [[TeamsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tvc.eventFilter = self.event;
    tvc.context = self.context;
    tvc.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    MatchResultsTableViewController *mrvc = [[MatchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    RankingsTableViewController *rvc = [[RankingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    self.controllers = @[eivc, tvc, mrvc, rvc];
    [self setViewControllers:@[[self.controllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.dataSource = self;
    self.delegate = self;

    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.context];
}

- (void)segmentPressed:(UISegmentedControl *)segment
{
    NSInteger oldIndex = [self.controllers indexOfObject:[self.viewControllers firstObject]];
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if(segment.selectedSegmentIndex < oldIndex) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    [self setViewControllers:@[self.controllers[segment.selectedSegmentIndex]] direction:direction animated:YES completion:nil];
}

// bug fix for uipageview controller, see http://stackoverflow.com/a/13253884
- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if(self.transitionStyle == UIPageViewControllerTransitionStyleScroll && animated) {
        __weak EventViewController *weakSelf = self;
        [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL finished) {
            if(finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                });
            }
            if(completion) {
                completion(finished);
            }
        }];
    } else {
        [super setViewControllers:viewControllers direction:direction animated:animated completion:completion];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index == 0) {
        return nil;
    } else {
        return self.controllers[index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index == self.controllers.count - 1) {
        return nil;
    } else {
        return self.controllers[index+1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *controller = [pageViewController.viewControllers firstObject];
    NSInteger index = [self.controllers indexOfObject:controller];
    self.segment.selectedSegmentIndex = index;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
 