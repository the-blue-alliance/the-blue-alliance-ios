// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.m instead.

#import "_Match.h"

const struct MatchAttributes MatchAttributes = {
	.blueScore = @"blueScore",
	.comp_level = @"comp_level",
	.key = @"key",
	.match_number = @"match_number",
	.redScore = @"redScore",
	.set_number = @"set_number",
	.time_string = @"time_string",
};

const struct MatchRelationships MatchRelationships = {
	.blueAlliance = @"blueAlliance",
	.event = @"event",
	.media = @"media",
	.redAlliance = @"redAlliance",
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
	if ([key isEqualToString:@"match_numberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"match_number"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"redScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"redScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"set_numberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"set_number"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic blueScore;

- (int32_t)blueScoreValue {
	NSNumber *result = [self blueScore];
	return [result intValue];
}

- (void)setBlueScoreValue:(int32_t)value_ {
	[self setBlueScore:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveBlueScoreValue {
	NSNumber *result = [self primitiveBlueScore];
	return [result intValue];
}

- (void)setPrimitiveBlueScoreValue:(int32_t)value_ {
	[self setPrimitiveBlueScore:[NSNumber numberWithInt:value_]];
}

@dynamic comp_level;

@dynamic key;

@dynamic match_number;

- (int32_t)match_numberValue {
	NSNumber *result = [self match_number];
	return [result intValue];
}

- (void)setMatch_numberValue:(int32_t)value_ {
	[self setMatch_number:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMatch_numberValue {
	NSNumber *result = [self primitiveMatch_number];
	return [result intValue];
}

- (void)setPrimitiveMatch_numberValue:(int32_t)value_ {
	[self setPrimitiveMatch_number:[NSNumber numberWithInt:value_]];
}

@dynamic redScore;

- (int32_t)redScoreValue {
	NSNumber *result = [self redScore];
	return [result intValue];
}

- (void)setRedScoreValue:(int32_t)value_ {
	[self setRedScore:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRedScoreValue {
	NSNumber *result = [self primitiveRedScore];
	return [result intValue];
}

- (void)setPrimitiveRedScoreValue:(int32_t)value_ {
	[self setPrimitiveRedScore:[NSNumber numberWithInt:value_]];
}

@dynamic set_number;

- (int32_t)set_numberValue {
	NSNumber *result = [self set_number];
	return [result intValue];
}

- (void)setSet_numberValue:(int32_t)value_ {
	[self setSet_number:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSet_numberValue {
	NSNumber *result = [self primitiveSet_number];
	return [result intValue];
}

- (void)setPrimitiveSet_numberValue:(int32_t)value_ {
	[self setPrimitiveSet_number:[NSNumber numberWithInt:value_]];
}

@dynamic time_string;

@dynamic blueAlliance;

- (NSMutableOrderedSet*)blueAllianceSet {
	[self willAccessValueForKey:@"blueAlliance"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"blueAlliance"];

	[self didAccessValueForKey:@"blueAlliance"];
	return result;
}

@dynamic event;

@dynamic media;

- (NSMutableSet*)mediaSet {
	[self willAccessValueForKey:@"media"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"media"];

	[self didAccessValueForKey:@"media"];
	return result;
}

@dynamic redAlliance;

- (NSMutableOrderedSet*)redAllianceSet {
	[self willAccessValueForKey:@"redAlliance"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"redAlliance"];

	[self didAccessValueForKey:@"redAlliance"];
	return result;
}

@end

@implementation _Match (BlueAllianceCoreDataGeneratedAccessors)
- (void)addBlueAlliance:(NSOrderedSet*)value_ {
	[self.blueAllianceSet unionOrderedSet:value_];
}
- (void)removeBlueAlliance:(NSOrderedSet*)value_ {
	[self.blueAllianceSet minusOrderedSet:value_];
}
- (void)addBlueAllianceObject:(Team*)value_ {
	[self.blueAllianceSet addObject:value_];
}
- (void)removeBlueAllianceObject:(Team*)value_ {
	[self.blueAllianceSet removeObject:value_];
}
- (void)insertObject:(Team*)value inBlueAllianceAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
- (void)removeObjectFromBlueAllianceAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
- (void)insertBlueAlliance:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
- (void)removeBlueAllianceAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
- (void)replaceObjectInBlueAllianceAtIndex:(NSUInteger)idx withObject:(Team*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
- (void)replaceBlueAllianceAtIndexes:(NSIndexSet *)indexes withBlueAlliance:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"blueAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self blueAlliance]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"blueAlliance"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"blueAlliance"];
}
@end

@implementation _Match (RedAllianceCoreDataGeneratedAccessors)
- (void)addRedAlliance:(NSOrderedSet*)value_ {
	[self.redAllianceSet unionOrderedSet:value_];
}
- (void)removeRedAlliance:(NSOrderedSet*)value_ {
	[self.redAllianceSet minusOrderedSet:value_];
}
- (void)addRedAllianceObject:(Team*)value_ {
	[self.redAllianceSet addObject:value_];
}
- (void)removeRedAllianceObject:(Team*)value_ {
	[self.redAllianceSet removeObject:value_];
}
- (void)insertObject:(Team*)value inRedAllianceAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"redAlliance"];
}
- (void)removeObjectFromRedAllianceAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"redAlliance"];
}
- (void)insertRedAlliance:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"redAlliance"];
}
- (void)removeRedAllianceAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"redAlliance"];
}
- (void)replaceObjectInRedAllianceAtIndex:(NSUInteger)idx withObject:(Team*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"redAlliance"];
}
- (void)replaceRedAllianceAtIndexes:(NSIndexSet *)indexes withRedAlliance:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"redAlliance"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self redAlliance]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"redAlliance"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"redAlliance"];
}
@end

