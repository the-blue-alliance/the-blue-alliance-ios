//
//  EventRanking+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventRanking.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventRanking (CoreDataProperties)

@property (nullable, nonatomic, retain) id info;
@property (nullable, nonatomic, retain) NSNumber *rank;
@property (nullable, nonatomic, retain) NSString *record;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) Team *team;

@end

NS_ASSUME_NONNULL_END
