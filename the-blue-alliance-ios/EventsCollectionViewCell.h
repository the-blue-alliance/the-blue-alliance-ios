//
//  EventsCollectionViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/23/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderedDictionary.h"

@interface EventsCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) OrderedDictionary *weekData;

@end
