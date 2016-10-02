//
//  Match+Fetch.h
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Match.h"

@interface Match (Fetch)

+ (nullable Match *)fetchMatchForKey:(nonnull NSString *)matchKey fromContext:(nonnull NSManagedObjectContext *)context;

@end
