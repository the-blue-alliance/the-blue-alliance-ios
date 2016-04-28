//
//  TBAViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/28/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBAPersistenceController;

@interface TBAViewController : UIViewController

@property (nonnull, nonatomic, strong) TBAPersistenceController *persistenceController;

@property (nullable, nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nullable, nonatomic, strong) IBOutlet UIView *segmentedControlView;

@property (nullable, nonatomic, strong) NSArray *refreshViewControllers;
@property (nullable, nonatomic, strong) NSArray *containerViews;

@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationTitleLabel;
@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationSubtitleLabel;

- (void)showView:(nonnull UIView *)showView;
- (void)updateInterface;
- (void)cancelRefreshes;

@end
