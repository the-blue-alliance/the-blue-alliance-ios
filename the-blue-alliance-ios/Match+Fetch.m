//
//  Match+Fetch.m
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Match+Fetch.h"

@implementation Match (Fetch)

+ (nullable Match *)fetchMatchForKey:(nonnull NSString *)matchKey fromContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Match"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", matchKey];
    [fetchRequest setPredicate:predicate];
    return [context executeFetchRequest:fetchRequest error:nil].firstObject;
}

@end
