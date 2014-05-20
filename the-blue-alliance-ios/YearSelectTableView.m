//
//  YearSelectTableView.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <POP/POP.h>

#import "YearSelectTableView.h"

@interface YearSelectTableView ()
@property (nonatomic, strong) UIView *dimView;
@end

@implementation YearSelectTableView

const int kYearSelectEdgePadding = 30;
const int kNumberOfYears = 23;

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.showing = FALSE;
        
        self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        self.dimView.backgroundColor = [UIColor blackColor];
        self.dimView.alpha = 0.;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimView];
        
        UITapGestureRecognizer *dimissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        dimissTap.numberOfTapsRequired = 1;
        [self.dimView addGestureRecognizer:dimissTap];
    }
    return self;
}

- (void)show
{
    NSLog(@"Showing...");
    
    POPSpringAnimation *springAnimation = [self pop_animationForKey:@"bounds"];
    if (!springAnimation) {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
    }
    
    springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.x, self.y, ([[UIApplication sharedApplication] keyWindow].width - (2 * kYearSelectEdgePadding)), ([[UIApplication sharedApplication] keyWindow].height - (2 * kYearSelectEdgePadding)))];

    POPSpringAnimation *dimShowAnimation = [self.dimView pop_animationForKey:@"alpha"];
    if (!dimShowAnimation) {
        dimShowAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    }
    
    dimShowAnimation.toValue = [NSNumber numberWithFloat:0.6];
    
    [self pop_addAnimation:springAnimation forKey:@"bounds"];
    [self.dimView pop_addAnimation:dimShowAnimation forKey:@"alpha"];

    self.showing = TRUE;
}

- (void)hide
{
    NSLog(@"Hiding...");
    
    POPSpringAnimation *springAnimation = [self pop_animationForKey:@"bounds"];
    if (!springAnimation) {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
    }

    springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, 0)];

    POPSpringAnimation *dimShowAnimation = [self.dimView pop_animationForKey:@"alpha"];
    if (!dimShowAnimation) {
        dimShowAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    }
    
    dimShowAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self pop_addAnimation:springAnimation forKey:@"bounds"];
    [self.dimView pop_addAnimation:dimShowAnimation forKey:@"alpha"];

    self.showing = FALSE;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfYears;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Year Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Year Cell"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", 2014 - indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hide];
}

@end
