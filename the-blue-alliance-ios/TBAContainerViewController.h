//
//  TBAContainerViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAPersistenceController.h"

@interface TBAContainerViewController : UIViewController

@property (nonnull, nonatomic, strong) TBAPersistenceController *persistenceController;

- (void)registerForChangeNotifications:(void (^_Nonnull)(id _Nonnull changedObject))changeBlock;

- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
