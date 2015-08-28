// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MatchAlliance.m instead.

#import "_MatchAlliance.h"

const struct MatchAllianceAttributes MatchAllianceAttributes = {
	.score = @"score",
	.teams = @"teams",
};

@implementation MatchAllianceID
@end

@implementation _MatchAlliance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MatchAlliance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MatchAlliance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MatchAlliance" inManagedObjectContext:moc_];
}

- (MatchAllianceID*)objectID {
	return (MatchAllianceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"scoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"score"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic score;

- (int64_t)scoreValue {
	NSNumber *result = [self score];
	return [result longLongValue];
}

- (void)setScoreValue:(int64_t)value_ {
	[self setScore:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveScoreValue {
	NSNumber *result = [self primitiveScore];
	return [result longLongValue];
}

- (void)setPrimitiveScoreValue:(int64_t)value_ {
	[self setPrimitiveScore:[NSNumber numberWithLongLong:value_]];
}

@dynamic teams;

@end

