//
//  Event.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * event_type;
@property (nonatomic, retain) NSString * short_name;
@property (nonatomic, retain) NSString * event_short;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * district_enum;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSString * venue;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSNumber * official;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * webcasts;
@property (nonatomic, retain) NSString * stats;
@property (nonatomic, retain) NSString * rankings;
@property (nonatomic, retain) NSNumber * last_updated;

@end
