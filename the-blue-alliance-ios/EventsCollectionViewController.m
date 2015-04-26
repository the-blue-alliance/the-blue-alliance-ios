//
//  EventsCollectionViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/23/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "EventsCollectionViewController.h"
#import "EventsCollectionViewCell.h"


static NSString *const EventsCollectionViewCellIdentifier = @"Events Collection View Cell";


@implementation EventsCollectionViewController

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.eventData) {
        return 0;
    }
    return [self.eventData.allKeys count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventsCollectionViewCell *cell = (EventsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:EventsCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSString *key = [self.eventData.allKeys objectAtIndex:indexPath.row];
    OrderedDictionary *weekData = [self.eventData valueForKey:key];
    
    cell.weekData = weekData;
    [cell.tableView reloadData];
    
    return cell;
}


@end
