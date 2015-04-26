//
//  TeamsCollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsCollectionViewController.h"
#import "TeamsCollectionViewCell.h"
#import "Team.h"


static NSString *const TeamsCollectionViewCellIdentifier = @"Teams Collection View Cell";


@implementation TeamsCollectionViewController

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.teams) {
        return 0;
    }
    return [self.teams count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TeamsCollectionViewCell *cell = (TeamsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TeamsCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSString *teamKey = [self.teams keyAtIndex:indexPath.row];
    NSArray *teamsSubArray = [self.teams objectForKey:teamKey];
    
    cell.teams = teamsSubArray;
    [cell.tableView reloadData];
    
    return cell;
}

@end
