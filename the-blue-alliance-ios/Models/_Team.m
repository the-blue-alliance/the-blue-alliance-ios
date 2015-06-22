// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.m instead.

#import "_Team.h"

const struct TeamAttributes TeamAttributes = {
	.countryName = @"countryName",
	.key = @"key",
	.locality = @"locality",
	.location = @"location",
	.name = @"name",
	.nickname = @"nickname",
	.region = @"region",
	.rookieYear = @"rookieYear",
	.teamNumber = @"teamNumber",
	.website = @"website",
	.yearsParticipated = @"yearsParticipated",
};

const struct TeamRelationships TeamRelationships = {
	.districtRankings = @"districtRankings",
	.eventPoints = @"eventPoints",
	.events = @"events",
	.media = @"media",
};

@implementation TeamID
@end

@implementation _Team

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Team";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Team" inManagedObjectContext:moc_];
}

- (TeamID*)objectID {
	return (TeamID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"rookieYearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rookieYear"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"teamNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"teamNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic countryName;

@dynamic key;

@dynamic locality;

@dynamic location;

@dynamic name;

@dynamic nickname;

@dynamic region;

@dynamic rookieYear;

- (int64_t)rookieYearValue {
	NSNumber *result = [self rookieYear];
	return [result longLongValue];
}

- (void)setRookieYearValue:(int64_t)value_ {
	[self setRookieYear:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRookieYearValue {
	NSNumber *result = [self primitiveRookieYear];
	return [result longLongValue];
}

- (void)setPrimitiveRookieYearValue:(int64_t)value_ {
	[self setPrimitiveRookieYear:[NSNumber numberWithLongLong:value_]];
}

@dynamic teamNumber;

- (uint64_t)teamNumberValue {
	NSNumber *result = [self teamNumber];
	return [result unsignedLongLongValue];
}

- (void)setTeamNumberValue:(uint64_t)value_ {
	[self setTeamNumber:[NSNumber numberWithUnsignedLongLong:value_]];
}

- (uint64_t)primitiveTeamNumberValue {
	NSNumber *result = [self primitiveTeamNumber];
	return [result unsignedLongLongValue];
}

- (void)setPrimitiveTeamNumberValue:(uint64_t)value_ {
	[self setPrimitiveTeamNumber:[NSNumber numberWithUnsignedLongLong:value_]];
}

@dynamic website;

@dynamic yearsParticipated;

@dynamic districtRankings;

- (NSMutableSet*)districtRankingsSet {
	[self willAccessValueForKey:@"districtRankings"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"districtRankings"];

	[self didAccessValueForKey:@"districtRankings"];
	return result;
}

@dynamic eventPoints;

- (NSMutableSet*)eventPointsSet {
	[self willAccessValueForKey:@"eventPoints"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"eventPoints"];

	[self didAccessValueForKey:@"eventPoints"];
	return result;
}

@dynamic events;

- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];

	[self didAccessValueForKey:@"events"];
	return result;
}

@dynamic media;

- (NSMutableSet*)mediaSet {
	[self willAccessValueForKey:@"media"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"media"];

	[self didAccessValueForKey:@"media"];
	return result;
}

@end

