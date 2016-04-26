//
//  AwardRecipient.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "AwardRecipient.h"
#import "Award.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "TBAAward.h"

@implementation AwardRecipient

@dynamic name;
@dynamic team;
@dynamic award;

+ (instancetype)insertAwardRecipientWithModelAwardRecipient:(TBAAwardRecipient *)modelAwardRecipient forAward:(Award *)award inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate;
    __block Team *team;
    if (modelAwardRecipient.teamNumber != 0) {
        NSString *teamNumber = [@(modelAwardRecipient.teamNumber) stringValue];
        NSString *teamKey = [NSString stringWithFormat:@"frc%@", teamNumber];

        team = [Team insertStubTeamWithKey:teamKey inManagedObjectContext:context];
        predicate = [NSPredicate predicateWithFormat:@"team == %@ AND award == %@", team, award];
    } else if (modelAwardRecipient.awardee) {
        predicate = [NSPredicate predicateWithFormat:@"name == %@ AND award == %@", modelAwardRecipient.awardee, award];
    }

    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(AwardRecipient *awardRecipient) {
        awardRecipient.team = team;
        awardRecipient.name = modelAwardRecipient.awardee;
        awardRecipient.award = award;
    }];
}

+ (NSArray *)insertAwardRecipientsWithModelAwardRecipients:(NSArray<TBAAwardRecipient *> *)modelAwardRecipients forAward:(Award *)award inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAAwardRecipient *awardRecipient in modelAwardRecipients) {
        [arr addObject:[self insertAwardRecipientWithModelAwardRecipient:awardRecipient forAward:award inManagedObjectContext:context]];
    }
    return arr;
}

@end
