// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventAlliance.m instead.

#import "_EventAlliance.h"

const struct EventAllianceAttributes EventAllianceAttributes = {
	.declines = @"declines",
	.picks = @"picks",
};

const struct EventAllianceRelationships EventAllianceRelationships = {
	.event = @"event",
};

@implementation EventAllianceID
@end

@implementation _EventAlliance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EventAlliance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EventAlliance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EventAlliance" inManagedObjectContext:moc_];
}

- (EventAllianceID*)objectID {
	return (EventAllianceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic declines;

@dynamic picks;

@dynamic event;

@end

