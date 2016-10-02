//
//  EventTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMyTBATableViewCell.h"

static NSString *const EventCellReuseIdentifier = @"EventCell";

@class Event;

@interface TBAEventTableViewCell : TBAMyTBATableViewCell

@property (nonatomic, strong) Event *event;

@end
