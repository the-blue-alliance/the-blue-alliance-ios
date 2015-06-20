//
//  MediaTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/13/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBAMediaTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end
