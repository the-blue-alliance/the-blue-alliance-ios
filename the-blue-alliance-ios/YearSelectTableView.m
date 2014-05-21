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
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *yearTableView;
@end

@implementation YearSelectTableView

const int kYearSelectEdgePadding = 30;
const int kNumberOfYears = 23;

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.showing = FALSE;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    int topBarHeight = 44;
    
    self.containerView = [[UIView alloc] initForAutoLayout];
    [self addSubview:self.containerView];
    [self.containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
    [self.containerView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self];
    [self.containerView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.containerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    
    // Top bar with some text
    UIView *topBar = [[UIView alloc] initForAutoLayout];
    topBar.backgroundColor = [UIColor orangeColor];
    [self.containerView addSubview:topBar];
    [topBar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.containerView];
    [topBar autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.containerView];
    [topBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.containerView];
    [topBar autoSetDimension:ALDimensionHeight toSize:topBarHeight];
    
    // Table view for the years
    self.yearTableView = [[UITableView alloc] initForAutoLayout];
    self.yearTableView.delegate = self;
    self.yearTableView.dataSource = self;
    [self.containerView addSubview:self.yearTableView];
    [self.yearTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topBar];
    [self.yearTableView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.containerView withOffset:0.];
    [self.yearTableView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.containerView];
    [self.yearTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.containerView];
    
    // Set up dimmed background view
    self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.alpha = 0.;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimView];
    
    UITapGestureRecognizer *dimissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    dimissTap.numberOfTapsRequired = 1;
    [self.dimView addGestureRecognizer:dimissTap];
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
