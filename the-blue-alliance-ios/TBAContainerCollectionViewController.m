//
//  TBAContainerCollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAContainerCollectionViewController.h"
#import "TBANoDataViewController.h"

@interface TBAContainerCollectionViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;
@property (nonatomic, strong) id changeObserver;

@end

@implementation TBAContainerCollectionViewController

#pragma mark - View Lifecycle

- (void)dealloc {
    [self removeChangeObserver];
}

#pragma mark - Private Methods

- (void)removeChangeObserver {
    if (self.changeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.changeObserver];
    }
}

#pragma mark - TBA Delegate Methods

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([self.tbaDelegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
}

#pragma mark - Public Methods

- (void)registerForChangeNotifications:(void (^_Nonnull)(id _Nonnull changedObject))changeBlock {
    [self removeChangeObserver];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            changeBlock(obj);
        }
    }];
}

- (void)clearFRC {
    self.fetchedResultsController = nil;
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)showNoDataViewWithText:(NSString *)text {
    if (!self.noDataViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.noDataViewController = [storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    }

    self.noDataViewController.view.alpha = 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setBackgroundView:self.noDataViewController.view];
    });
    
    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setBackgroundView:self.noDataViewController.view];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.noDataViewController.view.alpha = 1.0f;
        }];
    });
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView setBackgroundView:nil];
        });
    }
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        sections = self.fetchedResultsController.sections.count;
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        rows = [sectionInfo numberOfObjects];
        if (!rows || (rows && rows == 0 && self.tbaDelegate)) {
            [self.tbaDelegate showNoDataView];
        } else {
            [self hideNoDataView];
        }
    } else if (self.fetchedResultsController && self.tbaDelegate) {
        [self.tbaDelegate showNoDataView];
    }
    return rows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (self.tbaDelegate) {
        [self.tbaDelegate configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

@end
