//
//  Media+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Media.h"

NS_ASSUME_NONNULL_BEGIN

@interface Media (CoreDataProperties)

@property (nullable, nonatomic, retain) id cachedData;
@property (nullable, nonatomic, retain) NSString *foreignKey;
@property (nullable, nonatomic, retain) NSString *imagePartial;
@property (nullable, nonatomic, retain) NSNumber *mediaType;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) Team *team;

@end

NS_ASSUME_NONNULL_END
