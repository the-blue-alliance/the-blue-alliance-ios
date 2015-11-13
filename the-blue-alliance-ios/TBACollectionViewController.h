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

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface TBACollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) TBAPersistenceController *persistenceController;
@property (nonatomic, weak) id<TBACollectionViewControllerDelegate> tbaDelegate;

- (void)showNoDataViewWithText:(NSString *)text;
- (void)hideNoDataView;

@end
