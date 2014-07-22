// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.m instead.

#import "_Media.h"

const struct MediaAttributes MediaAttributes = {
	.cachedData = @"cachedData",
	.channel = @"channel",
	.key = @"key",
	.threadUrl = @"threadUrl",
	.title = @"title",
	.type = @"type",
	.url = @"url",
};

const struct MediaRelationships MediaRelationships = {
	.events = @"events",
	.matches = @"matches",
	.teams = @"teams",
};

const struct MediaFetchedProperties MediaFetchedProperties = {
};

@implementation MediaID
@end

@implementation _Media

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Media";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Media" inManagedObjectContext:moc_];
}

- (MediaID*)objectID {
	return (MediaID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic cachedData;






@dynamic channel;






@dynamic key;






@dynamic threadUrl;






@dynamic title;






@dynamic type;






@dynamic url;






@dynamic events;

	
- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];
  
	[self didAccessValueForKey:@"events"];
	return result;
}
	

@dynamic matches;

	
- (NSMutableSet*)matchesSet {
	[self willAccessValueForKey:@"matches"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matches"];
  
	[self didAccessValueForKey:@"matches"];
	return result;
}
	

@dynamic teams;

	
- (NSMutableSet*)teamsSet {
	[self willAccessValueForKey:@"teams"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"teams"];
  
	[self didAccessValueForKey:@"teams"];
	return result;
}
	






@end
