//
//  EventPoints+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EventPoints.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventPoints (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *alliancePoints;
@property (nullable, nonatomic, retain) NSNumber *awardPoints;
@property (nullable, nonatomic, retain) NSNumber *districtCMP;
@property (nullable, nonatomic, retain) NSNumber *elimPoints;
@property (nullable, nonatomic, retain) NSNumber *qualPoints;
@property (nullable, nonatomic, retain) NSNumber *total;
@property (nullable, nonatomic, retain) DistrictRanking *districtRanking;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) Team *team;

@end

NS_ASSUME_NONNULL_END
