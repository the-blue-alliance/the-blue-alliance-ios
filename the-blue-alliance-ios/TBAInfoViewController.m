//
//  TBAInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAInfoViewController.h"
#import "Team.h"
#import "Event.h"
#import "Media.h"
#import "OrderedDictionary.h"
#import "TBAMediaTableViewCell.h"
#import "TBAMediaCollectionViewCell.h"

static NSString *const InfoCellReuseIdentifier = @"InfoCell";
static NSString *const MediaCellReuseIdentifier = @"MediaCell";

@interface TBAInfoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL expandSponsors;
@property (nonatomic, strong) OrderedDictionary *infoDictionary;

@end

@implementation TBAInfoViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.media && [self.media count] != 0 ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        UITableViewCell *localCell = [tableView dequeueReusableCellWithIdentifier:InfoCellReuseIdentifier forIndexPath:indexPath];
        if (self.team.location && indexPath.row == 0) {
            localCell.textLabel.text = [NSString stringWithFormat:@"from %@", self.team.location];
            localCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (self.team.name && indexPath.row == 1) {
            localCell.textLabel.text = self.team.name;
            localCell.textLabel.numberOfLines = 2;
            
            localCell.accessoryType = UITableViewCellAccessoryDetailButton;
            localCell.tintColor = [UIColor colorWithRed:0.79 green:0.79 blue:0.81 alpha:1];
        }
        if (self.team.website && indexPath.row == 2) {
            localCell.textLabel.text = self.team.website;
            
            localCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell = localCell;
    } else {
        TBAMediaTableViewCell *localCell = (TBAMediaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MediaTableCell" forIndexPath:indexPath];
        localCell.collectionViewHeightConstraint.constant = [localCell.collectionView.collectionViewLayout collectionViewContentSize].height;
        [localCell.collectionView reloadData];
        
        cell = localCell;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self titleString];
    } else {
        return @"Media";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (section == 0 && [view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.textLabel.text = [self titleString];
        tableViewHeaderFooterView.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [self.infoDictionary keyAtIndex:indexPath.row];
    if ([key isEqualToString:@"sponsors"]) {
        self.expandSponsors = !self.expandSponsors;
        [self.tableView reloadData];
    }
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.media count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TBAMediaCollectionViewCell *cell = (TBAMediaCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MediaCellReuseIdentifier forIndexPath:indexPath];
    
    Media *media = [self.media objectAtIndex:indexPath.row];
    cell.media = media;
    
    return cell;
}


#pragma mark - Collection View Data Source

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80.0f, 80.0f);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (NSString *)titleString {
    if (self.team) {
        return [self.team nickname];
    } else {
        return self.event.name;
    }
}

@end
