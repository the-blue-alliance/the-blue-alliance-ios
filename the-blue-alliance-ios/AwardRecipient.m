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

+ (instancetype)insertAwardRecipientWithModelAwardRecipient:(TBAAwardRecipient *)modelAwardRecipient forAward:(Award *)award forTeam:(Team *)team withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(AwardRecipient *awardRecipient) {
        awardRecipient.team = team;
        awardRecipient.name = modelAwardRecipient.awardee;
        awardRecipient.award = award;
    }];
}

+ (NSArray *)insertAwardRecipientsWithModelAwardRecipients:(NSArray<TBAAwardRecipient *> *)modelAwardRecipients forAward:(Award *)award inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAAwardRecipient *awardRecipient in modelAwardRecipients) {
        NSPredicate *predicate;
        __block Team *team;
        if (awardRecipient.teamNumber != 0) {
            NSString *teamNumber = [@(awardRecipient.teamNumber) stringValue];
            NSString *teamKey = [NSString stringWithFormat:@"frc%@", teamNumber];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [Team fetchTeamWithKey:teamKey inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull t, NSError * _Nonnull error) {
                team = t;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (!team) {
                continue;
            }
            
            predicate = [NSPredicate predicateWithFormat:@"team == %@ AND award == %@", team, award];
        } else if (awardRecipient.awardee) {
            predicate = [NSPredicate predicateWithFormat:@"name == %@ AND award == %@", awardRecipient.awardee, award];
        }
        
        [arr addObject:[self insertAwardRecipientWithModelAwardRecipient:awardRecipient forAward:award forTeam:team withPredicate:predicate inManagedObjectContext:context]];
    }
    return arr;
}

@end
