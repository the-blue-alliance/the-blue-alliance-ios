//
//  EventTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class Event;

@interface TBAEventTableViewCell : TBATableViewCell

@property (nonatomic, strong) Event *event;

@end
