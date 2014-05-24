//
//  Team.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSNumber * team_number;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSSet *events;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
