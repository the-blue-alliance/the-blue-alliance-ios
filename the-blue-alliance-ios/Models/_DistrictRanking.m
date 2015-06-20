// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DistrictRanking.m instead.

#import "_DistrictRanking.h"

const struct DistrictRankingAttributes DistrictRankingAttributes = {
	.pointTotal = @"pointTotal",
	.rank = @"rank",
	.rookieBonus = @"rookieBonus",
};

const struct DistrictRankingRelationships DistrictRankingRelationships = {
	.district = @"district",
	.eventPoints = @"eventPoints",
	.team = @"team",
};

@implementation DistrictRankingID
@end

@implementation _DistrictRanking

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DistrictRanking" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DistrictRanking";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DistrictRanking" inManagedObjectContext:moc_];
}

- (DistrictRankingID*)objectID {
	return (DistrictRankingID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"pointTotalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pointTotal"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rookieBonusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rookieBonus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic pointTotal;

- (int32_t)pointTotalValue {
	NSNumber *result = [self pointTotal];
	return [result intValue];
}

- (void)setPointTotalValue:(int32_t)value_ {
	[self setPointTotal:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePointTotalValue {
	NSNumber *result = [self primitivePointTotal];
	return [result intValue];
}

- (void)setPrimitivePointTotalValue:(int32_t)value_ {
	[self setPrimitivePointTotal:[NSNumber numberWithInt:value_]];
}

@dynamic rank;

- (int32_t)rankValue {
	NSNumber *result = [self rank];
	return [result intValue];
}

- (void)setRankValue:(int32_t)value_ {
	[self setRank:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRankValue {
	NSNumber *result = [self primitiveRank];
	return [result intValue];
}

- (void)setPrimitiveRankValue:(int32_t)value_ {
	[self setPrimitiveRank:[NSNumber numberWithInt:value_]];
}

@dynamic rookieBonus;

- (int32_t)rookieBonusValue {
	NSNumber *result = [self rookieBonus];
	return [result intValue];
}

- (void)setRookieBonusValue:(int32_t)value_ {
	[self setRookieBonus:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRookieBonusValue {
	NSNumber *result = [self primitiveRookieBonus];
	return [result intValue];
}

- (void)setPrimitiveRookieBonusValue:(int32_t)value_ {
	[self setPrimitiveRookieBonus:[NSNumber numberWithInt:value_]];
}

@dynamic district;

@dynamic eventPoints;

- (NSMutableSet*)eventPointsSet {
	[self willAccessValueForKey:@"eventPoints"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"eventPoints"];

	[self didAccessValueForKey:@"eventPoints"];
	return result;
}

@dynamic team;

@end

