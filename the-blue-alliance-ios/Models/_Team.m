// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.m instead.

#import "_Team.h"

const struct TeamAttributes TeamAttributes = {
	.address = @"address",
	.cachedLocationLat = @"cachedLocationLat",
	.cachedLocationLon = @"cachedLocationLon",
	.cachedLocationRadius = @"cachedLocationRadius",
	.grouping_text = @"grouping_text",
	.key = @"key",
	.last_updated = @"last_updated",
	.location = @"location",
	.name = @"name",
	.nickname = @"nickname",
	.rookieYear = @"rookieYear",
	.team_number = @"team_number",
	.website = @"website",
};

const struct TeamRelationships TeamRelationships = {
	.events = @"events",
	.matchesWhereBlue = @"matchesWhereBlue",
	.matchesWhereRed = @"matchesWhereRed",
	.media = @"media",
};

const struct TeamFetchedProperties TeamFetchedProperties = {
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
	
	if ([key isEqualToString:@"cachedLocationLatValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cachedLocationLat"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cachedLocationLonValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cachedLocationLon"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cachedLocationRadiusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cachedLocationRadius"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_updatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_updated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rookieYearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rookieYear"];
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




@dynamic address;






@dynamic cachedLocationLat;



- (double)cachedLocationLatValue {
	NSNumber *result = [self cachedLocationLat];
	return [result doubleValue];
}

- (void)setCachedLocationLatValue:(double)value_ {
	[self setCachedLocationLat:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveCachedLocationLatValue {
	NSNumber *result = [self primitiveCachedLocationLat];
	return [result doubleValue];
}

- (void)setPrimitiveCachedLocationLatValue:(double)value_ {
	[self setPrimitiveCachedLocationLat:[NSNumber numberWithDouble:value_]];
}





@dynamic cachedLocationLon;



- (double)cachedLocationLonValue {
	NSNumber *result = [self cachedLocationLon];
	return [result doubleValue];
}

- (void)setCachedLocationLonValue:(double)value_ {
	[self setCachedLocationLon:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveCachedLocationLonValue {
	NSNumber *result = [self primitiveCachedLocationLon];
	return [result doubleValue];
}

- (void)setPrimitiveCachedLocationLonValue:(double)value_ {
	[self setPrimitiveCachedLocationLon:[NSNumber numberWithDouble:value_]];
}





@dynamic cachedLocationRadius;



- (double)cachedLocationRadiusValue {
	NSNumber *result = [self cachedLocationRadius];
	return [result doubleValue];
}

- (void)setCachedLocationRadiusValue:(double)value_ {
	[self setCachedLocationRadius:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveCachedLocationRadiusValue {
	NSNumber *result = [self primitiveCachedLocationRadius];
	return [result doubleValue];
}

- (void)setPrimitiveCachedLocationRadiusValue:(double)value_ {
	[self setPrimitiveCachedLocationRadius:[NSNumber numberWithDouble:value_]];
}





@dynamic grouping_text;






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






@dynamic nickname;






@dynamic rookieYear;



- (int32_t)rookieYearValue {
	NSNumber *result = [self rookieYear];
	return [result intValue];
}

- (void)setRookieYearValue:(int32_t)value_ {
	[self setRookieYear:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRookieYearValue {
	NSNumber *result = [self primitiveRookieYear];
	return [result intValue];
}

- (void)setPrimitiveRookieYearValue:(int32_t)value_ {
	[self setPrimitiveRookieYear:[NSNumber numberWithInt:value_]];
}





@dynamic team_number;



- (int32_t)team_numberValue {
	NSNumber *result = [self team_number];
	return [result intValue];
}

- (void)setTeam_numberValue:(int32_t)value_ {
	[self setTeam_number:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTeam_numberValue {
	NSNumber *result = [self primitiveTeam_number];
	return [result intValue];
}

- (void)setPrimitiveTeam_numberValue:(int32_t)value_ {
	[self setPrimitiveTeam_number:[NSNumber numberWithInt:value_]];
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
