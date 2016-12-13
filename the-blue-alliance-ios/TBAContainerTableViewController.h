//
//  TBAContainerTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/11/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@protocol TBATableViewControllerDelegate <NSObject>

@required

- (void)configureCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)showNoDataView;

@end

@interface TBAContainerTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nullable, nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonnull, nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nullable, nonatomic, weak) id<TBATableViewControllerDelegate> tbaDelegate;
@property (nonnull, nonatomic, copy) NSString *cellIdentifier;

- (void)registerForChangeNotifications:(void (^_Nonnull)(id _Nonnull changedObject))changeBlock;
- (void)clearFRC;

- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
