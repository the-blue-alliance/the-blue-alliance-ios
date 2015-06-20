// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to District.m instead.

#import "_District.h"

const struct DistrictAttributes DistrictAttributes = {
	.key = @"key",
	.name = @"name",
	.year = @"year",
};

const struct DistrictRelationships DistrictRelationships = {
	.districtRankings = @"districtRankings",
};

@implementation DistrictID
@end

@implementation _District

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"District" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"District";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"District" inManagedObjectContext:moc_];
}

- (DistrictID*)objectID {
	return (DistrictID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic key;

@dynamic name;

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

@dynamic districtRankings;

- (NSMutableSet*)districtRankingsSet {
	[self willAccessValueForKey:@"districtRankings"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"districtRankings"];

	[self didAccessValueForKey:@"districtRankings"];
	return result;
}

@end

