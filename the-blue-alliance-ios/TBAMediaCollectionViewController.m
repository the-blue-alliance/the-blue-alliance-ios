//
//  TBAMediaCollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/17/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMediaCollectionViewController.h"
#import "TBAPlayerView.h"
#import "TBAMediaView.h"
#import "TBAMedia.h"
#import "Media.h"
#import "Team.h"

static NSString *const MediaCellReuseIdentifier = @"MediaCell";

@interface TBAMediaCollectionViewController ()

// Key is video ID, value is an instanciated player view with that ID
@property (nonatomic, strong) NSMutableDictionary<NSString *, TBAPlayerView *> *playerViews;
// Key is an image foreign key, value is a downloaded UIImage or a null if not completed
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *downloadedImages;

@end

@implementation TBAMediaCollectionViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSMutableDictionary *)playerViews {
    if (!_playerViews) {
        _playerViews = [[NSMutableDictionary alloc] init];
    }
    return _playerViews;
}

- (NSMutableDictionary *)downloadedImages {
    if (!_downloadedImages) {
        _downloadedImages = [[NSMutableDictionary alloc] init];
    }
    return _downloadedImages;
}

- (void)setYear:(NSNumber *)year {
    _year = year;
    
    self.playerViews = nil;
    self.downloadedImages = nil;
    [self clearFRC];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    if (!self.persistenceController) {
        return nil;
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
    __block NSUInteger request = [[TBAKit sharedKit] fetchMediaForTeamKey:self.team.key andYear:self.year.integerValue withCompletionBlock:^(NSArray *media, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load team media"];
        }
        
        Team *team = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.team.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            [Media insertMediasWithModelMedias:media forTeam:team andYear:strongSelf.year.integerValue inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Private Methods

- (TBAPlayerView *)playerViewForMedia:(Media *)media {
    TBAPlayerView *playerView = self.playerViews[media.foreignKey];
    if (!playerView) {
        playerView = [[TBAPlayerView alloc] init];
        playerView.media = media;

        self.playerViews[media.foreignKey] = playerView;
    }
    return playerView;
}

- (TBAMediaView *)mediaViewForMedia:(Media *)media {
    UIImage *downloadedImage = self.downloadedImages[media.foreignKey];
    
    TBAMediaView *mediaView = [[TBAMediaView alloc] init];
    mediaView.downloadedImage = downloadedImage;
    mediaView.media = media;
    mediaView.imageDownloaded = ^(UIImage *image) {
        self.downloadedImages[media.foreignKey] = image;
    };
    return mediaView;
}

#pragma mark - TBA Table View Data Soruce

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Media *media = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIView *mediaView;
    if (media.mediaType.integerValue == TBAMediaTypeYouTube) {
        mediaView = [self playerViewForMedia:media];
    } else if (media.mediaType.integerValue == TBAMediaTypeCDPhotoThread) {
        mediaView = [self mediaViewForMedia:media];
    }
    [cell.contentView addSubview:mediaView];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:mediaView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [cell.contentView addConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No media found for this team"];
}

#pragma mark - Rotation Methods

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Collection View Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger horizontalSizeClass = self.traitCollection.horizontalSizeClass;
    
    NSInteger numberPerLine = 2;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        numberPerLine = 3;
    }
    
    CGFloat spacerSize = 3;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    CGFloat cellWidth = (viewWidth - (spacerSize * 2) - (spacerSize * (numberPerLine - 1)))/numberPerLine;
    return CGSizeMake(cellWidth, cellWidth);
}

@end
