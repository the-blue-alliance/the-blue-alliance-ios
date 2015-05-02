// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.m instead.

#import "_Team.h"

const struct TeamAttributes TeamAttributes = {
	.country = @"country",
	.key = @"key",
	.last_updated = @"last_updated",
	.locality = @"locality",
	.location = @"location",
	.name = @"name",
	.nickname = @"nickname",
	.region = @"region",
	.rookie_year = @"rookie_year",
	.team_number = @"team_number",
	.website = @"website",
};

const struct TeamRelationships TeamRelationships = {
	.events = @"events",
	.matchesWhereBlue = @"matchesWhereBlue",
	.matchesWhereRed = @"matchesWhereRed",
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

	if ([key isEqualToString:@"last_updatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_updated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rookie_yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rookie_year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"team_numberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"team_number"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic country;

@dynamic key;

@dynamic last_updated;

- (int64_t)last_updatedValue {
	NSNumber *result = [self last_updated];
	return [result longLongValue];
}

- (void)setLast_updatedValue:(int64_t)value_ {
	[self setLast_updated:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLast_updatedValue {
	NSNumber *result = [self primitiveLast_updated];
	return [result longLongValue];
}

- (void)setPrimitiveLast_updatedValue:(int64_t)value_ {
	[self setPrimitiveLast_updated:[NSNumber numberWithLongLong:value_]];
}

@dynamic locality;

@dynamic location;

@dynamic name;

@dynamic nickname;

@dynamic region;

@dynamic rookie_year;

- (int32_t)rookie_yearValue {
	NSNumber *result = [self rookie_year];
	return [result intValue];
}

- (void)setRookie_yearValue:(int32_t)value_ {
	[self setRookie_year:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRookie_yearValue {
	NSNumber *result = [self primitiveRookie_year];
	return [result intValue];
}

- (void)setPrimitiveRookie_yearValue:(int32_t)value_ {
	[self setPrimitiveRookie_year:[NSNumber numberWithInt:value_]];
}

@dynamic team_number;

- (uint32_t)team_numberValue {
	NSNumber *result = [self team_number];
	return [result unsignedIntValue];
}

- (void)setTeam_numberValue:(uint32_t)value_ {
	[self setTeam_number:[NSNumber numberWithUnsignedInt:value_]];
}

- (uint32_t)primitiveTeam_numberValue {
	NSNumber *result = [self primitiveTeam_number];
	return [result unsignedIntValue];
}

- (void)setPrimitiveTeam_numberValue:(uint32_t)value_ {
	[self setPrimitiveTeam_number:[NSNumber numberWithUnsignedInt:value_]];
}

@dynamic website;

@dynamic events;

- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];

	[self didAccessValueForKey:@"events"];
	return result;
}

@dynamic matchesWhereBlue;

- (NSMutableSet*)matchesWhereBlueSet {
	[self willAccessValueForKey:@"matchesWhereBlue"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matchesWhereBlue"];

	[self didAccessValueForKey:@"matchesWhereBlue"];
	return result;
}

@dynamic matchesWhereRed;

- (NSMutableSet*)matchesWhereRedSet {
	[self willAccessValueForKey:@"matchesWhereRed"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matchesWhereRed"];

	[self didAccessValueForKey:@"matchesWhereRed"];
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

