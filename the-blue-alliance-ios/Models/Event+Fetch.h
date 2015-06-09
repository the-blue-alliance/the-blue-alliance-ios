//
//  Event+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event.h"

@interface Event (Fetch)

// Locally
+ (void)fetchEventForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *events, NSError *error))completion;
+ (void)fetchEventForKey:(NSString *)eventKey fromContext:(NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^)(Event *event, NSError *error))completion;

@end
