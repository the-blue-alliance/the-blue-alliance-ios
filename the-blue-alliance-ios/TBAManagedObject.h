//
//  TBAManagedObject.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/23/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TBAManagedObject : NSManagedObject

NS_ASSUME_NONNULL_BEGIN

+ (nonnull instancetype)findOrCreateInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate configure:(void (^)(id obj))configure;
+ (nullable instancetype)findOrFetchInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate;
+ (NSArray<__kindof TBAManagedObject *> *)fetchInContext:(NSManagedObjectContext *)context configure:(void (^)(NSFetchRequest *fetchRequest))configure;
+ (instancetype)materializedObjectInContext:(NSManagedObjectContext *)context matchingPredicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
