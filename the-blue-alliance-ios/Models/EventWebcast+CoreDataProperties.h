//
//  EventWebcast+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventWebcast.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventWebcast (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *channel;
@property (nullable, nonatomic, retain) NSString *file;
@property (nullable, nonatomic, retain) NSNumber *webcastType;
@property (nullable, nonatomic, retain) Event *event;

@end

NS_ASSUME_NONNULL_END
