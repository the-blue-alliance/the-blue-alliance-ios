//
//  MatchVideo+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MatchVideo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MatchVideo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSNumber *videoType;
@property (nullable, nonatomic, retain) Match *match;

@end

NS_ASSUME_NONNULL_END
