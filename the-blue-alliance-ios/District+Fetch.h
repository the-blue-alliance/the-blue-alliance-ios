//
//  District+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/16/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District.h"

@interface District (Fetch)

+ (void)fetchEventsForDistrict:(nonnull District *)district fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray *_Nullable events, NSError * _Nullable error))completion;

@end
