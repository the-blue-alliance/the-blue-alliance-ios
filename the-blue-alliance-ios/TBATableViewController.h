//
//  TBATableViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/11/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAPersistenceController.h"

@protocol TBATableViewControllerDelegate <NSObject>

@required

- (void)configureCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)showNoDataView;

@end

@interface TBATableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nullable, nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonnull, nonatomic, strong) TBAPersistenceController *persistenceController;
@property (nullable, nonatomic, weak) id<TBATableViewControllerDelegate> tbaDelegate;
@property (nonnull, nonatomic, copy) NSString *cellIdentifier;

- (void)clearFRC;
- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
