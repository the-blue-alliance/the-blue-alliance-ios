// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.m instead.

#import "_Event.h"

const struct EventAttributes EventAttributes = {
	.endDate = @"endDate",
	.eventCode = @"eventCode",
	.eventDistrict = @"eventDistrict",
	.eventType = @"eventType",
	.facebookEid = @"facebookEid",
	.key = @"key",
	.location = @"location",
	.name = @"name",
	.official = @"official",
	.shortName = @"shortName",
	.startDate = @"startDate",
	.venueAddress = @"venueAddress",
	.website = @"website",
	.year = @"year",
};

const struct EventRelationships EventRelationships = {
	.alliances = @"alliances",
	.points = @"points",
	.teams = @"teams",
	.webcasts = @"webcasts",
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

	if ([key isEqualToString:@"eventTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"eventType"];
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

@dynamic endDate;

@dynamic eventCode;

@dynamic eventDistrict;

@dynamic eventType;

- (int32_t)eventTypeValue {
	NSNumber *result = [self eventType];
	return [result intValue];
}

- (void)setEventTypeValue:(int32_t)value_ {
	[self setEventType:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveEventTypeValue {
	NSNumber *result = [self primitiveEventType];
	return [result intValue];
}

- (void)setPrimitiveEventTypeValue:(int32_t)value_ {
	[self setPrimitiveEventType:[NSNumber numberWithInt:value_]];
}

@dynamic facebookEid;

@dynamic key;

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

@dynamic shortName;

@dynamic startDate;

@dynamic venueAddress;

@dynamic website;

@dynamic year;

- (int64_t)yearValue {
	NSNumber *result = [self year];
	return [result longLongValue];
}

- (void)setYearValue:(int64_t)value_ {
	[self setYear:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result longLongValue];
}

- (void)setPrimitiveYearValue:(int64_t)value_ {
	[self setPrimitiveYear:[NSNumber numberWithLongLong:value_]];
}

@dynamic alliances;

- (NSMutableSet*)alliancesSet {
	[self willAccessValueForKey:@"alliances"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"alliances"];

	[self didAccessValueForKey:@"alliances"];
	return result;
}

@dynamic points;

- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];

	[self didAccessValueForKey:@"points"];
	return result;
}

@dynamic teams;

- (NSMutableSet*)teamsSet {
	[self willAccessValueForKey:@"teams"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"teams"];

	[self didAccessValueForKey:@"teams"];
	return result;
}

@dynamic webcasts;

- (NSMutableSet*)webcastsSet {
	[self willAccessValueForKey:@"webcasts"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"webcasts"];

	[self didAccessValueForKey:@"webcasts"];
	return result;
}

@end

