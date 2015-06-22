//
//  Media+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Media.h"

@interface Media (Fetch)

+ (void)fetchMediaForYear:(NSInteger)year forTeam:(Team *)team fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *media, NSError *error))completion;

@end
