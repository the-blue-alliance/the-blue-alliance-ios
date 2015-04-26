//
//  TeamsTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end
