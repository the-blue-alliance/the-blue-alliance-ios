//
//  Team.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBATeam;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * locality;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic) int64_t teamNumber;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic) int64_t rookieYear;

// Insertion
+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertTeamsWithModelTeams:(NSArray *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context;

@end
