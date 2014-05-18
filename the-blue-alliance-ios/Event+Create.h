//
//  Event+TBA.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event.h"

@interface Event (Create)

+ (Event *)createEventFromTBAInfo:(NSDictionary *)info
         usingManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)createEventsFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context;

@end
