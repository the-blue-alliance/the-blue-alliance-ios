//
//  TBACollectionViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAPersistenceController.h"

@protocol TBACollectionViewControllerDelegate <NSObject>

@required

- (void)configureCell:(nonnull UICollectionViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath;

@end

@interface TBACollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (null_resettable, nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nullable, nonatomic, strong) TBAPersistenceController *persistenceController;
@property (nullable, nonatomic, weak) id<TBACollectionViewControllerDelegate> tbaDelegate;
@property (nonnull, nonatomic, copy) NSString *cellIdentifier;

- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
