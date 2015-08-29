//
//  TBACollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBACollectionViewController.h"
#import "TBANoDataViewController.h"

@interface TBACollectionViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;

@end

@implementation TBACollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - No Data Views

- (void)showNoDataViewWithText:(NSString *)text {
    self.noDataViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    
    self.noDataViewController.view.alpha = 0.0f;
    [self.collectionView setBackgroundView:self.noDataViewController.view];
    
    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.noDataViewController.view.alpha = 1.0f;
    }];
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        [self.collectionView setBackgroundView:nil];
    }
}

#pragma mark - TBA Delegate Methods

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([self.tbaDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - Fetched Results Controller Delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UICollectionView *collectionView = self.collectionView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

@end
