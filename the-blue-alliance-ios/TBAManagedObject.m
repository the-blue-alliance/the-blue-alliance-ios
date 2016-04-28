//
//  TBAManagedObject.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/23/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"
#import "Team.h"

@implementation TBAManagedObject

+ (NSString *)entityName {
    return NSStringFromClass([self class]);
}

+ (nonnull instancetype)findOrCreateInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate configure:(void (^)(id obj))configure {
    TBAManagedObject *obj = [self findOrFetchInContext:context matchingPredicate:predicate];
    if (!obj) {
        obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    }
    configure(obj);
    return obj;
}

+ (nullable instancetype)findOrFetchInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate {
    TBAManagedObject *obj = [self materializedObjectInContext:context matchingPredicate:predicate];
    if (obj) {
        return obj;
    }
    
    return [self fetchInContext:context configure:^(NSFetchRequest *fetchRequest) {
        fetchRequest.predicate = predicate;
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchLimit = 1;
    }].firstObject;
}

+ (NSArray<__kindof TBAManagedObject *> *)fetchInContext:(NSManagedObjectContext *)context configure:(void (^)(NSFetchRequest *fetchRequest))configure {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
    configure(request);
    return [context executeFetchRequest:request error:nil];
}

+ (instancetype)materializedObjectInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate {
    for (NSManagedObject *obj in context.registeredObjects) {
        if (obj.fault)
            continue;
        if ([predicate isKindOfClass:[self class]] && [predicate evaluateWithObject:obj]) {
            return (TBAManagedObject *)obj;
        }
    }
    return nil;
}

@end
