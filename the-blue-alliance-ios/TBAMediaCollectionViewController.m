//
//  TBAMediaCollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/17/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMediaCollectionViewController.h"
#import "TBAMediaCollectionViewCell.h"
#import "Media.h"
#import "Team.h"

static NSString *const MediaCellReuseIdentifier = @"MediaCell";

@implementation TBAMediaCollectionViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (void)setYear:(NSUInteger)year {
    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:[self cacheName]];
    
    _year = year;
    [self.collectionView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND team == %@", @(self.year), self.team];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *mediaTypeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"mediaType" ascending:YES];
    [fetchRequest setSortDescriptors:@[mediaTypeSortDescriptor]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:[self cacheName]];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
}

#pragma mark - Private Methods

- (NSString *)cacheName {
    return [NSString stringWithFormat:@"%zd%@_media", self.year, self.team.key];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    } else {
        // TODO: Show no data screen;
        count = 0;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TBAMediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MediaCellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TBAMediaCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = nil;
    
    Media *media = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.media = media;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0f, 150.0f);
}

@end
