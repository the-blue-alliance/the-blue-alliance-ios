// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.m instead.

#import "_Event.h"

const struct EventAttributes EventAttributes = {
	.address = @"address",
	.alliances = @"alliances",
	.district_points = @"district_points",
	.end_date = @"end_date",
	.event_district = @"event_district",
	.event_short = @"event_short",
	.event_type = @"event_type",
	.key = @"key",
	.last_updated = @"last_updated",
	.location = @"location",
	.name = @"name",
	.official = @"official",
	.short_name = @"short_name",
	.start_date = @"start_date",
	.venue = @"venue",
	.website = @"website",
	.year = @"year",
};

const struct EventRelationships EventRelationships = {
	.matches = @"matches",
	.media = @"media",
	.teams = @"teams",
};

@implementation EventID
@end

@implementation _Event

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Event";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc_];
}

- (EventID*)objectID {
	return (EventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"event_districtValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"event_district"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"event_typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"event_type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_updatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_updated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"officialValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"official"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic address;

@dynamic alliances;

@dynamic district_points;

@dynamic end_date;

@dynamic event_district;

- (int32_t)event_districtValue {
	NSNumber *result = [self event_district];
	return [result intValue];
}

- (void)setEvent_districtValue:(int32_t)value_ {
	[self setEvent_district:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveEvent_districtValue {
	NSNumber *result = [self primitiveEvent_district];
	return [result intValue];
}

- (void)setPrimitiveEvent_districtValue:(int32_t)value_ {
	[self setPrimitiveEvent_district:[NSNumber numberWithInt:value_]];
}

@dynamic event_short;

@dynamic event_type;

- (int32_t)event_typeValue {
	NSNumber *result = [self event_type];
	return [result intValue];
}

- (void)setEvent_typeValue:(int32_t)value_ {
	[self setEvent_type:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveEvent_typeValue {
	NSNumber *result = [self primitiveEvent_type];
	return [result intValue];
}

- (void)setPrimitiveEvent_typeValue:(int32_t)value_ {
	[self setPrimitiveEvent_type:[NSNumber numberWithInt:value_]];
}

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

@dynamic location;

@dynamic name;

@dynamic official;

- (BOOL)officialValue {
	NSNumber *result = [self official];
	return [result boolValue];
}

- (void)setOfficialValue:(BOOL)value_ {
	[self setOfficial:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveOfficialValue {
	NSNumber *result = [self primitiveOfficial];
	return [result boolValue];
}

- (void)setPrimitiveOfficialValue:(BOOL)value_ {
	[self setPrimitiveOfficial:[NSNumber numberWithBool:value_]];
}

@dynamic short_name;

@dynamic start_date;

@dynamic venue;

@dynamic website;

@dynamic year;

- (int32_t)yearValue {
	NSNumber *result = [self year];
	return [result intValue];
}

- (void)setYearValue:(int32_t)value_ {
	[self setYear:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result intValue];
}

- (void)setPrimitiveYearValue:(int32_t)value_ {
	[self setPrimitiveYear:[NSNumber numberWithInt:value_]];
}

@dynamic matches;

- (NSMutableSet*)matchesSet {
	[self willAccessValueForKey:@"matches"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"matches"];

	[self didAccessValueForKey:@"matches"];
	return result;
}

@dynamic media;

- (NSMutableSet*)mediaSet {
	[self willAccessValueForKey:@"media"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"media"];

	[self didAccessValueForKey:@"media"];
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

