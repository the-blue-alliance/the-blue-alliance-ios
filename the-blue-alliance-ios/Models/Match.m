#import "Match.h"
#import "MatchVideo.h"

@interface Match ()

// Private interface goes here.

@end

@implementation Match

+ (instancetype)insertMatchWithModelMatch:(TBAMatch *)modelMatch forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Match" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", modelMatch.key];
    [fetchRequest setPredicate:predicate];
    
    Match *match;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        event = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (Match *m in existingObjs) {
            [context deleteObject:m];
        }
    }
    
    if (match == nil) {
        match = [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:context];
    }
    
    match.key = modelMatch.key;
    match.compLevel = @([self compLevelForString:modelMatch.compLevel]);
    match.setNumber = @(modelMatch.setNumber);
    match.matchNumber = @(modelMatch.matchNumber);
    match.scoreBreakdown = modelMatch.scoreBreakdown;
    match.time = modelMatch.time;
    match.event = event;

    match.redAlliance = modelMatch.redAlliance.teams;
    match.redScore = @(modelMatch.redAlliance.score);
    
    match.blueAlliance = modelMatch.blueAlliance.teams;
    match.blueScore = @(modelMatch.blueAlliance.score);
    
    match.vidoes = [NSSet setWithArray:[MatchVideo insertMatchVidoesWithModelMatchVidoes:modelMatch.videos inManagedObjectContext:context]];
    
    return match;
}

+ (NSArray *)insertMatchesWithModelMatches:(NSArray *)modelMatches forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAMatch *match in modelMatches) {
        [arr addObject:[self insertMatchWithModelMatch:match forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

+ (CompLevel)compLevelForString:(NSString *)compLevelString {
    CompLevel compLevel;
    if ([compLevelString isEqualToString:@"qm"]) {
        compLevel = CompLevelQualification;
    } else if ([compLevelString isEqualToString:@"ef"] || [compLevelString isEqualToString:@"qf"]) {
        compLevel = CompLevelQuarterFinal;
    } else if ([compLevelString isEqualToString:@"sf"]) {
        compLevel = CompLevelSemiFinal;
    } else if ([compLevelString isEqualToString:@"f"]) {
        compLevel = CompLevelFinal;
    }
    return compLevel;
}

@end
