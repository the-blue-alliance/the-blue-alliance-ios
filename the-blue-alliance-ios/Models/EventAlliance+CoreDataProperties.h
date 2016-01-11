//
//  EventAlliance+CoreDataProperties.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventAlliance.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventAlliance (CoreDataProperties)

@property (nullable, nonatomic, retain) NSArray<NSString *> *declines;
@property (nullable, nonatomic, retain) NSArray<NSString *> *picks;
@property (nullable, nonatomic, retain) NSNumber *allianceNumber;
@property (nullable, nonatomic, retain) Event *event;

@end

NS_ASSUME_NONNULL_END
