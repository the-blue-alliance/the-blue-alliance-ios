// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.m instead.

#import "_Match.h"

const struct MatchAttributes MatchAttributes = {
	.blueAlliance = @"blueAlliance",
	.blueScore = @"blueScore",
	.compLevel = @"compLevel",
	.key = @"key",
	.matchNumber = @"matchNumber",
	.redAlliance = @"redAlliance",
	.redScore = @"redScore",
	.scoreBreakdown = @"scoreBreakdown",
	.setNumber = @"setNumber",
	.time = @"time",
};

const struct MatchRelationships MatchRelationships = {
	.event = @"event",
	.vidoes = @"vidoes",
};

@implementation MatchID
@end

@implementation _Match

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Match";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Match" inManagedObjectContext:moc_];
}

- (MatchID*)objectID {
	return (MatchID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"blueScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"blueScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"compLevelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"compLevel"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"matchNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"matchNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"redScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"redScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"setNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"setNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic blueAlliance;

@dynamic blueScore;

- (int64_t)blueScoreValue {
	NSNumber *result = [self blueScore];
	return [result longLongValue];
}

- (void)setBlueScoreValue:(int64_t)value_ {
	[self setBlueScore:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveBlueScoreValue {
	NSNumber *result = [self primitiveBlueScore];
	return [result longLongValue];
}

- (void)setPrimitiveBlueScoreValue:(int64_t)value_ {
	[self setPrimitiveBlueScore:[NSNumber numberWithLongLong:value_]];
}

@dynamic compLevel;

- (int64_t)compLevelValue {
	NSNumber *result = [self compLevel];
	return [result longLongValue];
}

- (void)setCompLevelValue:(int64_t)value_ {
	[self setCompLevel:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCompLevelValue {
	NSNumber *result = [self primitiveCompLevel];
	return [result longLongValue];
}

- (void)setPrimitiveCompLevelValue:(int64_t)value_ {
	[self setPrimitiveCompLevel:[NSNumber numberWithLongLong:value_]];
}

@dynamic key;

@dynamic matchNumber;

- (int64_t)matchNumberValue {
	NSNumber *result = [self matchNumber];
	return [result longLongValue];
}

- (void)setMatchNumberValue:(int64_t)value_ {
	[self setMatchNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMatchNumberValue {
	NSNumber *result = [self primitiveMatchNumber];
	return [result longLongValue];
}

- (void)setPrimitiveMatchNumberValue:(int64_t)value_ {
	[self setPrimitiveMatchNumber:[NSNumber numberWithLongLong:value_]];
}

@dynamic redAlliance;

@dynamic redScore;

- (int64_t)redScoreValue {
	NSNumber *result = [self redScore];
	return [result longLongValue];
}

- (void)setRedScoreValue:(int64_t)value_ {
	[self setRedScore:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRedScoreValue {
	NSNumber *result = [self primitiveRedScore];
	return [result longLongValue];
}

- (void)setPrimitiveRedScoreValue:(int64_t)value_ {
	[self setPrimitiveRedScore:[NSNumber numberWithLongLong:value_]];
}

@dynamic scoreBreakdown;

@dynamic setNumber;

- (int64_t)setNumberValue {
	NSNumber *result = [self setNumber];
	return [result longLongValue];
}

- (void)setSetNumberValue:(int64_t)value_ {
	[self setSetNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSetNumberValue {
	NSNumber *result = [self primitiveSetNumber];
	return [result longLongValue];
}

- (void)setPrimitiveSetNumberValue:(int64_t)value_ {
	[self setPrimitiveSetNumber:[NSNumber numberWithLongLong:value_]];
}

@dynamic time;

@dynamic event;

@dynamic vidoes;

- (NSMutableSet*)vidoesSet {
	[self willAccessValueForKey:@"vidoes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"vidoes"];

	[self didAccessValueForKey:@"vidoes"];
	return result;
}

@end

