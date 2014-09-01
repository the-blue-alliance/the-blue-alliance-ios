//
//  NSManagedObject+Create.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "NSManagedObject+Create.h"

@implementation NSManagedObject (Create)


// Validates the dictionary and makes it safe to pull data from
+ (NSDictionary *)normalizeInfoDictionary:(NSDictionary *)info
{
    NSMutableDictionary *normInfo = [info mutableCopy];
    
    NSSet *nullSet = [normInfo keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return obj == [NSNull null];
    }];
    [normInfo removeObjectsForKeys:[nullSet allObjects]];
    
    return normInfo;
}

+ (instancetype)createManagedObjectFromInfo:(NSDictionary *)info
          checkingPrexistanceUsingUniqueKey:(NSString *)key
                  usingManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self createManagedObjectFromInfo:info checkingPrexistanceUsingUniqueKey:key usingManagedObjectContext:context userInfo:nil];
}

+ (instancetype)createManagedObjectFromInfo:(NSDictionary *)info
          checkingPrexistanceUsingUniqueKey:(NSString *)key
                  usingManagedObjectContext:(NSManagedObjectContext *)context
                                   userInfo:(id)userInfo {
    
    // Check for implementation of protocol
    NSString *className = NSStringFromClass([self class]);
    if(![self conformsToProtocol:@protocol(NSManagedObjectCreatable)]) {
        [NSException raise:@"Invalid use of `createManagedObjectFromInfo:usingManagedObjectContext:" format:@"Class %@ does not conform to the NSManagedObjectCreatable protocol!", className];
        return nil;
    }
    
    // Check for pre-existing object
    NSManagedObject<NSManagedObjectCreatable> *object = nil;
    if(key) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@", key];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
        if(existingObjs.count == 1) {
            object = [existingObjs firstObject];
        } else if(existingObjs.count > 1) {
            [NSException raise:@"Corrup database!" format:@"There are multiple %@'s with unique key %@", className, key];
            return nil;
        }
    }
    
    if(object == nil) {
        object = [NSEntityDescription insertNewObjectForEntityForName:className
                                               inManagedObjectContext:context];
    }
    
    // Validates the dictionary and makes it safe to pull data from
    info = [NSManagedObject normalizeInfoDictionary:info];
    
    
    [object configureSelfForInfo:info usingManagedObjectContext:context withUserInfo:userInfo];
    
//    NSLog(@"Imported object %@ into the database", object);
    
    return object;
}



+ (NSArray *)createManagedObjectsFromInfoArray:(NSArray *)infoArray
             checkingPrexistanceUsingUniqueKey:(NSString *)key
                     usingManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createManagedObjectsFromInfoArray:infoArray checkingPrexistanceUsingUniqueKey:key usingManagedObjectContext:context userInfo:nil];
    
}

+ (NSArray *)createManagedObjectsFromInfoArray:(NSArray *)infoArray
             checkingPrexistanceUsingUniqueKey:(NSString *)key
                     usingManagedObjectContext:(NSManagedObjectContext *)context
                                      userInfo:(id)userInfo {
    
    NSMutableArray *returnObjs = [[NSMutableArray alloc] init];
    
    NSMutableArray *givenKeys = [[NSMutableArray alloc] init];
    for (NSDictionary *info in infoArray) {
        [givenKeys addObject:info[key]];
    }
    
    NSString *className = NSStringFromClass([self class]);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", givenKeys];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if (existingObjs == nil) {
        NSLog(@"Core Data error: handle this error... :(");
    }
    
    NSMutableSet *existingKeySet = [[NSMutableSet alloc] init];
    NSMutableDictionary *existingObjsDict = [[NSMutableDictionary alloc] init];
    for (NSManagedObject *obj in existingObjs) {
        [existingKeySet addObject:[obj valueForKey:key]];
        existingObjsDict[[obj valueForKey:key]] = obj;
    }
    
    
    for (NSDictionary *infoDict in infoArray) {
        if(![existingKeySet containsObject:infoDict[key]]) {
            [returnObjs addObject:[self createManagedObjectFromInfo:infoDict
                                  checkingPrexistanceUsingUniqueKey:nil
                                          usingManagedObjectContext:context
                                                           userInfo:userInfo]];
        } else {
            NSManagedObject *existingObject = existingObjsDict[infoDict[key]];
            if([existingObject conformsToProtocol:@protocol(NSManagedObjectCreatable)]) {
                NSManagedObject<NSManagedObjectCreatable> *creatable = (NSManagedObject<NSManagedObjectCreatable> *)existingObject;
                
                [creatable configureSelfForInfo:[NSManagedObject normalizeInfoDictionary:infoDict] usingManagedObjectContext:context withUserInfo:userInfo];
            }
            
            [returnObjs addObject:existingObjsDict[infoDict[key]]];
        }
    }
    
    return returnObjs;
}


@end
