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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface TBATableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) TBAPersistenceController *persistenceController;
@property (nonatomic, weak) id<TBATableViewControllerDelegate> tbaDelegate;

- (void)showNoDataViewWithText:(NSString *)text;
- (void)hideNoDataView;

@end
