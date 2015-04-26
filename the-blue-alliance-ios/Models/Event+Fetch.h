//
//  Event+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/21/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event.h"

@interface Event (Fetch)

+ (NSArray *)fetchEventsForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context;

@end
