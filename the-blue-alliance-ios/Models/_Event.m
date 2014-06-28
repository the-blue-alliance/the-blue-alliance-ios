// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.m instead.

#import "_Event.h"

const struct EventAttributes EventAttributes = {
	.address = @"address",
	.district_enum = @"district_enum",
	.end_date = @"end_date",
	.event_short = @"event_short",
	.event_type = @"event_type",
	.key = @"key",
	.last_updated = @"last_updated",
	.location = @"location",
	.name = @"name",
	.official = @"official",
	.rankings = @"rankings",
	.short_name = @"short_name",
	.start_date = @"start_date",
	.stats = @"stats",
	.timezone = @"timezone",
	.venue = @"venue",
	.webcasts = @"webcasts",
	.website = @"website",
	.week = @"week",
	.year = @"year",
};

const struct EventRelationships EventRelationships = {
	.matches = @"matches",
	.teams = @"teams",
};

const struct EventFetchedProperties EventFetchedProperties = {
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
	
	if ([key isEqualToString:@"district_enumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"district_enum"];
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
	if ([key isEqualToString:@"weekValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"week"];
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






@dynamic district_enum;



- (int32_t)district_enumValue {
	NSNumber *result = [self district_enum];
	return [result intValue];
}

- (void)setDistrict_enumValue:(int32_t)value_ {
	[self setDistrict_enum:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDistrict_enumValue {
	NSNumber *result = [self primitiveDistrict_enum];
	return [result intValue];
}

- (void)setPrimitiveDistrict_enumValue:(int32_t)value_ {
	[self setPrimitiveDistrict_enum:[NSNumber numberWithInt:value_]];
}





@dynamic end_date;






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





@dynamic rankings;






@dynamic short_name;






@dynamic start_date;






@dynamic stats;






@dynamic timezone;






@dynamic venue;






@dynamic webcasts;






@dynamic website;






@dynamic week;



- (int32_t)weekValue {
	NSNumber *result = [self week];
	return [result intValue];
}

- (void)setWeekValue:(int32_t)value_ {
	[self setWeek:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveWeekValue {
	NSNumber *result = [self primitiveWeek];
	return [result intValue];
}

- (void)setPrimitiveWeekValue:(int32_t)value_ {
	[self setPrimitiveWeek:[NSNumber numberWithInt:value_]];
}





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
	

@dynamic teams;

	
- (NSMutableSet*)teamsSet {
	[self willAccessValueForKey:@"teams"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"teams"];
  
	[self didAccessValueForKey:@"teams"];
	return result;
}
	






@end
