//
//  AwardRecipient.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class TBAAwardRecipient, Award, Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface AwardRecipient : TBAManagedObject

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Team *team;
@property (nonatomic, retain) Award *award;

+ (AwardRecipient *)insertAwardRecipientWithModelAwardRecipient:(TBAAwardRecipient *)modelAwardRecipient forAward:(Award *)award inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <AwardRecipient *> *)insertAwardRecipientsWithModelAwardRecipients:(NSArray<TBAAwardRecipient *> *)modelAwardRecipients forAward:(Award *)award inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
