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

@implementation TBAMediaCollectionViewController

static NSString *const MediaCellReuseIdentifier = @"MediaCell";

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.media count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TBAMediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MediaCellReuseIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    
    Media *media = [self.media objectAtIndex:indexPath.row];
    cell.media = media;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0f, 150.0f);
}

@end
