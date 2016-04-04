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

+ (instancetype)insertAwardRecipientWithModelAwardRecipient:(TBAAwardRecipient *)modelAwardRecipient forAward:(Award *)award forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AwardRecipient" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate;
    __block Team *team;
    if (modelAwardRecipient.teamNumber != 0) {
        dispatch_semaphore_t teamSemaphore = dispatch_semaphore_create(0);
        
        NSString *teamKey = [NSString stringWithFormat:@"frc%ld", modelAwardRecipient.teamNumber];
        [Team fetchTeamForKey:teamKey fromContext:context checkUpstream:YES withCompletionBlock:^(Team *localTeam, NSError *error) {
            if (error || !localTeam) {
                dispatch_semaphore_signal(teamSemaphore);
            } else {
                team = localTeam;
                dispatch_semaphore_signal(teamSemaphore);
            }
        }];
        dispatch_semaphore_wait(teamSemaphore, DISPATCH_TIME_FOREVER);
        
        predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@ AND award == %@", event, team, award];
    } else if (modelAwardRecipient.awardee) {
        predicate = [NSPredicate predicateWithFormat:@"name == %@ AND event == %@ AND award == %@", modelAwardRecipient.awardee, event, award];
    }
    
    // Specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:predicate];
    
    AwardRecipient *awardRecipient;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        awardRecipient = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (AwardRecipient *aw in existingObjs) {
            [context deleteObject:aw];
        }
    }
    
    if (awardRecipient == nil) {
        awardRecipient = [NSEntityDescription insertNewObjectForEntityForName:@"AwardRecipient" inManagedObjectContext:context];
    }
    
    awardRecipient.event = event;
    awardRecipient.team = team;
    awardRecipient.name = modelAwardRecipient.awardee;
    awardRecipient.award = award;
    
    return awardRecipient;
}

+ (NSArray *)insertAwardRecipientsWithModelAwardRecipients:(NSArray<TBAAwardRecipient *> *)modelAwardRecipients forAward:(Award *)award forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAAwardRecipient *awardRecipient in modelAwardRecipients) {
        [arr addObject:[self insertAwardRecipientWithModelAwardRecipient:awardRecipient forAward:award forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
