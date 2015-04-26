//
//  EventTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *datesLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end
