//
//  TBAViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/28/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@class TBARefreshViewController;

@interface TBAViewController : UIViewController

@property (nonnull, readonly) NSPersistentContainer *persistentContainer;

@property (nullable, nonatomic, strong) NSArray<TBARefreshViewController *> *refreshViewControllers;
@property (nullable, nonatomic, strong) NSArray<UIView *> *containerViews;

@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationTitleLabel;
@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationSubtitleLabel;
@property (nullable, nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

- (void)cancelRefreshes;

@end
