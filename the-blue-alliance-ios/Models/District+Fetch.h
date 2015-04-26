//
//  District+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District.h"

@interface District (Fetch)

+ (NSArray *)fetchDistrictsForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context;

@end
