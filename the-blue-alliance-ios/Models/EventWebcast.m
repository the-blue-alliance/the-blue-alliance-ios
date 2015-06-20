#import "EventWebcast.h"

@interface EventWebcast ()

// Private interface goes here.

@end

@implementation EventWebcast

+ (instancetype)insertEventWebcastWithModelEventWebcast:(TBAEventWebcast *)modelEventWebcast forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventWebcast" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND type == %@ AND channel == %@",
                              event, @(modelEventWebcast.type), modelEventWebcast.channel];;
    [fetchRequest setPredicate:predicate];
    
    EventWebcast *eventWebcast;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        eventWebcast = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (EventWebcast *ew in existingObjs) {
            [context deleteObject:ew];
        }
    }
    
    if (eventWebcast == nil) {
        eventWebcast = [NSEntityDescription insertNewObjectForEntityForName:@"EventWebcast" inManagedObjectContext:context];
    }
    
    eventWebcast.webcastTypeValue = modelEventWebcast.type;
    eventWebcast.channel = modelEventWebcast.channel;
    eventWebcast.file = modelEventWebcast.file;
    eventWebcast.event = event;
    
    return eventWebcast;
}

+ (NSArray *)insertEventWebcastsWithModelEventWebcasts:(NSArray *)modelEventWebcasts forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAEventWebcast *eventWebcast in modelEventWebcasts) {
        [arr addObject:[self insertEventWebcastWithModelEventWebcast:eventWebcast forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
