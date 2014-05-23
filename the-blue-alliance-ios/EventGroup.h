//
//  EventGroup.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface EventGroup : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *events;

- (id)initWithName:(NSString*)name;
- (void)addEvent:(Event*)event;
@end
