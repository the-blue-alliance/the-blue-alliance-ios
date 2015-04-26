//
//  NSManagedObject+Create.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol NSManagedObjectCreatable <NSObject>

- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context
                withUserInfo:(id)userInfo;

@end


@interface NSManagedObject (Create)

+ (instancetype)createManagedObjectFromInfo:(NSDictionary *)info
          checkingPrexistanceUsingUniqueKey:(NSString *)key
      usingManagedObjectContext:(NSManagedObjectContext *)context;


+ (NSArray *)createManagedObjectsFromInfoArray:(NSArray *)infoArray
             checkingPrexistanceUsingUniqueKey:(NSString *)key
               usingManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)createManagedObjectsFromInfoArray:(NSArray *)infoArray
             checkingPrexistanceUsingUniqueKey:(NSString *)key
                     usingManagedObjectContext:(NSManagedObjectContext *)context
                                      userInfo:(id)info;

@end
