//
//  Award.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Award.h"
#import "AwardRecipient.h"
#import "Event.h"

@implementation Award

+ (instancetype)insertAwardWithModelAward:(TBAAward *)modelAward forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Award" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"awardType == %@ && year == %@ && event == %@", @(modelAward.awardType), @(modelAward.year), event];
    [fetchRequest setPredicate:predicate];
    
    Award *award;
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        award = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (Award *a in existingObjs) {
            [context deleteObject:a];
        }
    }

    if (award == nil) {
        award = [NSEntityDescription insertNewObjectForEntityForName:@"Award" inManagedObjectContext:context];
    }
    
    award.name = modelAward.name;
    award.year = @(modelAward.year);
    award.awardType = @(modelAward.awardType);
    award.event = event;
    award.recipients = [NSSet setWithArray:[AwardRecipient insertAwardRecipientsWithModelAwardRecipients:modelAward.recipientList forAward:award forEvent:event inManagedObjectContext:context]];
    
    return award;
}

+ (NSArray<Award *> *)insertAwardsWithModelAwards:(NSArray<TBAAward *> *)modelAwards forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAAward *award in modelAwards) {
        [arr addObject:[self insertAwardWithModelAward:award forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
