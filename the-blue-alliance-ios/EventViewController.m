//
//  EventViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventViewController.h"
#import "TBAImporter.h"
#import "TeamsViewController.h"

@interface EventViewController ()
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSArray *controllers;
@end

@implementation EventViewController

- (instancetype) initWithEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if(self) {
        self.event = event;
        self.context = context;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.event.short_name;
    
    TeamsViewController *vc = [[TeamsViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.eventFilter = self.event;
    vc.context = self.context;
    
    
    self.controllers = @[vc];
    [self setViewControllers:@[[self.controllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.dataSource = self;

    
    [TBAImporter linkTeamsToEvent:self.event usingManagedObjectContext:self.context];
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index == 0) {
        return nil;
    } else {
        return self.controllers[index-1];
    }
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index == self.controllers.count - 1) {
        return nil;
    } else {
        return self.controllers[index+1];
    }
}



@end
 