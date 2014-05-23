//
//  EventGroup.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventGroup.h"

@implementation EventGroup

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        self.name = name;
        self.events = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addEvent:(Event*)event
{
    [self.events addObject:event];
}

@end
