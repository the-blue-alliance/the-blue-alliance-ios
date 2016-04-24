//
//  Award.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class TBAAward, AwardRecipient, Event;

NS_ASSUME_NONNULL_BEGIN

@interface Award : TBAManagedObject

@property (nonatomic, retain) NSNumber *awardType;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *year;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSSet<AwardRecipient *> *recipients;

+ (Award *)insertAwardWithModelAward:(TBAAward *)modelAward forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Award *> *)insertAwardsWithModelAwards:(NSArray<TBAAward *> *)modelAwards forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
