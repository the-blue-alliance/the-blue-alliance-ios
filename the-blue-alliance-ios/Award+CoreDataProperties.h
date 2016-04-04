//
//  Award+CoreDataProperties.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Award.h"

NS_ASSUME_NONNULL_BEGIN

@interface Award (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *awardType;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) NSSet<AwardRecipient *> *recipients;

@end

NS_ASSUME_NONNULL_END
