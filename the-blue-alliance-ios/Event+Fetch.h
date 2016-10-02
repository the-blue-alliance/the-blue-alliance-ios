//
//  Event+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event.h"

@interface Event (Fetch)

+ (void)fetchEventsForYear:(NSUInteger)year fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray<Event *> *_Nullable events, NSError *_Nullable error))completion;

+ (nullable Event *)fetchEventForKey:(nonnull NSString *)eventKey fromContext:(nonnull NSManagedObjectContext *)context;

+ (void)fetchEventForKey:(nonnull NSString *)eventKey fromContext:(nonnull NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^_Nullable)(Event *_Nullable event, NSError *_Nullable error))completion;

@end
