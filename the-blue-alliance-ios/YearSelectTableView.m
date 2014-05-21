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
@property (nonatomic, strong) UITableView *yearTableView;
@end

@implementation YearSelectTableView

const int kYearSelectEdgePadding = 30;
const int kNumberOfYears = 23;

- (id)init {
    self = [super init];
    if (self) {
        self.currentYear = 2014;
        self.backgroundColor = [UIColor whiteColor];
        self.showing = FALSE;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    int topBarHeight = 44;
    
    // Top bar with some text
    UIView *topBar = [[UIView alloc] initForAutoLayout];
    topBar.backgroundColor = [UIColor orangeColor];
    [self addSubview:topBar];
    [topBar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
    [topBar autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self];
    [topBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [topBar autoSetDimension:ALDimensionHeight toSize:topBarHeight];
    
    // Table view for the years
    self.yearTableView = [[UITableView alloc] initForAutoLayout];
    self.yearTableView.delegate = self;
    self.yearTableView.dataSource = self;
    [self addSubview:self.yearTableView];
    [self.yearTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topBar];
    [self.yearTableView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withOffset:-topBarHeight];
    [self.yearTableView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self];
    [self.yearTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    
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

    POPSpringAnimation *springAnimation = [self pop_animationForKey:@"frame"];
    if (!springAnimation) {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    }
    
    springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(kYearSelectEdgePadding, kYearSelectEdgePadding, ([[UIApplication sharedApplication] keyWindow].width - (2 * kYearSelectEdgePadding)), ([[UIApplication sharedApplication] keyWindow].height - (2 * kYearSelectEdgePadding)))];

    POPSpringAnimation *dimShowAnimation = [self.dimView pop_animationForKey:@"alpha"];
    if (!dimShowAnimation) {
        dimShowAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    }
    
    dimShowAnimation.toValue = [NSNumber numberWithFloat:0.6];
    
    [self pop_addAnimation:springAnimation forKey:@"frame"];
    [self.dimView pop_addAnimation:dimShowAnimation forKey:@"alpha"];
    
    self.showing = TRUE;
}

- (void)hide
{
    NSLog(@"Hiding...");
    
    POPSpringAnimation *springAnimation = [self pop_animationForKey:@"frame"];
    if (!springAnimation) {
        springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    }

    springAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(self.centerX, self.centerY, 0, 0)];

    POPSpringAnimation *dimShowAnimation = [self.dimView pop_animationForKey:@"alpha"];
    if (!dimShowAnimation) {
        dimShowAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    }
    
    dimShowAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self pop_addAnimation:springAnimation forKey:@"frame"];
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
    
    if ((2014 - indexPath.row) == self.currentYear)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%ld", 2014 - indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newYearCell = [tableView cellForRowAtIndexPath:indexPath];
    self.currentYear = [newYearCell.textLabel.text integerValue];
    
    [tableView reloadData];
    
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });
}

@end
