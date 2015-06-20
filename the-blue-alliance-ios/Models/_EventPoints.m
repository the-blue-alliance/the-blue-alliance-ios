// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventPoints.m instead.

#import "_EventPoints.h"

const struct EventPointsAttributes EventPointsAttributes = {
	.alliancePoints = @"alliancePoints",
	.awardPoints = @"awardPoints",
	.districtCMP = @"districtCMP",
	.elimPoints = @"elimPoints",
	.qualPoints = @"qualPoints",
	.total = @"total",
};

const struct EventPointsRelationships EventPointsRelationships = {
	.districtRanking = @"districtRanking",
	.event = @"event",
	.team = @"team",
};

@implementation EventPointsID
@end

@implementation _EventPoints

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EventPoints" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EventPoints";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EventPoints" inManagedObjectContext:moc_];
}

- (EventPointsID*)objectID {
	return (EventPointsID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"alliancePointsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"alliancePoints"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"awardPointsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"awardPoints"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"districtCMPValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"districtCMP"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"elimPointsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"elimPoints"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"qualPointsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"qualPoints"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"total"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic alliancePoints;

- (int64_t)alliancePointsValue {
	NSNumber *result = [self alliancePoints];
	return [result longLongValue];
}

- (void)setAlliancePointsValue:(int64_t)value_ {
	[self setAlliancePoints:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveAlliancePointsValue {
	NSNumber *result = [self primitiveAlliancePoints];
	return [result longLongValue];
}

- (void)setPrimitiveAlliancePointsValue:(int64_t)value_ {
	[self setPrimitiveAlliancePoints:[NSNumber numberWithLongLong:value_]];
}

@dynamic awardPoints;

- (int64_t)awardPointsValue {
	NSNumber *result = [self awardPoints];
	return [result longLongValue];
}

- (void)setAwardPointsValue:(int64_t)value_ {
	[self setAwardPoints:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveAwardPointsValue {
	NSNumber *result = [self primitiveAwardPoints];
	return [result longLongValue];
}

- (void)setPrimitiveAwardPointsValue:(int64_t)value_ {
	[self setPrimitiveAwardPoints:[NSNumber numberWithLongLong:value_]];
}

@dynamic districtCMP;

- (BOOL)districtCMPValue {
	NSNumber *result = [self districtCMP];
	return [result boolValue];
}

- (void)setDistrictCMPValue:(BOOL)value_ {
	[self setDistrictCMP:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDistrictCMPValue {
	NSNumber *result = [self primitiveDistrictCMP];
	return [result boolValue];
}

- (void)setPrimitiveDistrictCMPValue:(BOOL)value_ {
	[self setPrimitiveDistrictCMP:[NSNumber numberWithBool:value_]];
}

@dynamic elimPoints;

- (int64_t)elimPointsValue {
	NSNumber *result = [self elimPoints];
	return [result longLongValue];
}

- (void)setElimPointsValue:(int64_t)value_ {
	[self setElimPoints:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveElimPointsValue {
	NSNumber *result = [self primitiveElimPoints];
	return [result longLongValue];
}

- (void)setPrimitiveElimPointsValue:(int64_t)value_ {
	[self setPrimitiveElimPoints:[NSNumber numberWithLongLong:value_]];
}

@dynamic qualPoints;

- (int64_t)qualPointsValue {
	NSNumber *result = [self qualPoints];
	return [result longLongValue];
}

- (void)setQualPointsValue:(int64_t)value_ {
	[self setQualPoints:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveQualPointsValue {
	NSNumber *result = [self primitiveQualPoints];
	return [result longLongValue];
}

- (void)setPrimitiveQualPointsValue:(int64_t)value_ {
	[self setPrimitiveQualPoints:[NSNumber numberWithLongLong:value_]];
}

@dynamic total;

- (int64_t)totalValue {
	NSNumber *result = [self total];
	return [result longLongValue];
}

- (void)setTotalValue:(int64_t)value_ {
	[self setTotal:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalValue {
	NSNumber *result = [self primitiveTotal];
	return [result longLongValue];
}

- (void)setPrimitiveTotalValue:(int64_t)value_ {
	[self setPrimitiveTotal:[NSNumber numberWithLongLong:value_]];
}

@dynamic districtRanking;

@dynamic event;

@dynamic team;

@end

