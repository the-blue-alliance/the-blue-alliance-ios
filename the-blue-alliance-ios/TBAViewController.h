//
//  TBAViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAPersistenceController.h"

@interface TBAViewController : UIViewController

@property (nonnull, nonatomic, strong) TBAPersistenceController *persistenceController;

@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationTitleLabel;
@property (nullable, nonatomic, strong) IBOutlet UILabel *navigationSubtitleLabel;

- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
