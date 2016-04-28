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

- (void)setYear:(NSNumber *)year {
    _year = year;
    
    [self clearFRC];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND team == %@", self.year, self.team];
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

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshData {
    if (self.year == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMediaForTeamKey:self.team.key andYear:self.year.integerValue withCompletionBlock:^(NSArray *media, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load team media"];
        } else {
            Team *team = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.team.objectID];
            
            [strongSelf.persistenceController performChanges:^{
                [Media insertMediasWithModelMedias:media forTeam:team andYear:strongSelf.year.integerValue inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            }];
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
