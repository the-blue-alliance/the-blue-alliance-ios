//
//  Media+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Media+Fetch.h"

@implementation Media (Fetch)

+ (void)fetchMediaForYear:(NSInteger)year forTeam:(Team *)team fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *media, NSError *error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND team == %@", @(year), team];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *media = [context executeFetchRequest:fetchRequest error:&error];
    if (completion) {
        completion(media, error);
    }
}

@end
