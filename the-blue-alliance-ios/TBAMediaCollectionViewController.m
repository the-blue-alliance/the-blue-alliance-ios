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
                                                                               cacheName:nil];
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
    self.cellIdentifier = MediaCellReuseIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshData];
    };
}

#pragma mark - Data Methods

- (void)refreshData {
    if (self.year == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMediaForTeamKey:self.team.key andYear:self.year withCompletionBlock:^(NSArray *media, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf showErrorAlertWithMessage:@"Unable to load team media"];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Media insertMediasWithModelMedias:media forTeam:self.team andYear:self.year inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf.persistenceController save];
                [strongSelf.collectionView reloadData];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Soruce

- (void)configureCell:(TBAMediaCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = nil;
    
    Media *media = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.media = media;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No media found for this team"];
}

#pragma mark - Collection View Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0f, 150.0f);
}

@end
