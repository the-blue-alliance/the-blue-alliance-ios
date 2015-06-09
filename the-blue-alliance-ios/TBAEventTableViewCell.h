//
//  EventTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface TBAEventTableViewCell : UITableViewCell

@property (nonatomic, weak) Event *event;

@end
