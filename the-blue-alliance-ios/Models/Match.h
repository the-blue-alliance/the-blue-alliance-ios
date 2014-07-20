//
//  Match.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_Match.h"
#import "NSManagedObject+Create.h"

@interface Match : _Match <NSManagedObjectCreatable>

@property (nonatomic, readonly) NSString *friendlyMatchName;

@end
