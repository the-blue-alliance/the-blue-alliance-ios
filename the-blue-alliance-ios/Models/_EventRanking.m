// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventRanking.m instead.

#import "_EventRanking.h"

const struct EventRankingAttributes EventRankingAttributes = {
	.info = @"info",
	.rank = @"rank",
	.record = @"record",
};

const struct EventRankingRelationships EventRankingRelationships = {
	.event = @"event",
	.team = @"team",
};

@implementation EventRankingID
@end

@implementation _EventRanking

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EventRanking" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EventRanking";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EventRanking" inManagedObjectContext:moc_];
}

- (EventRankingID*)objectID {
	return (EventRankingID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"rankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic info;

@dynamic rank;

- (int64_t)rankValue {
	NSNumber *result = [self rank];
	return [result longLongValue];
}

- (void)setRankValue:(int64_t)value_ {
	[self setRank:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRankValue {
	NSNumber *result = [self primitiveRank];
	return [result longLongValue];
}

- (void)setPrimitiveRankValue:(int64_t)value_ {
	[self setPrimitiveRank:[NSNumber numberWithLongLong:value_]];
}

@dynamic record;

@dynamic event;

@dynamic team;

@end

