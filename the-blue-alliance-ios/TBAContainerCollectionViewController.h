//
//  TBAContainerCollectionViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@protocol TBACollectionViewControllerDelegate <NSObject>

@required

- (void)configureCell:(nonnull UICollectionViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)showNoDataView;

@end

@interface TBAContainerCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (nullable, nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nullable, nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nullable, nonatomic, weak) id<TBACollectionViewControllerDelegate> tbaDelegate;
@property (nonnull, nonatomic, copy) NSString *cellIdentifier;

- (void)registerForChangeNotifications:(void (^_Nonnull)(id _Nonnull changedObject))changeBlock;
- (void)clearFRC;

- (void)showErrorAlertWithMessage:(nonnull NSString *)message;
- (void)showNoDataViewWithText:(nonnull NSString *)text;
- (void)hideNoDataView;

@end
