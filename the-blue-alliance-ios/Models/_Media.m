// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.m instead.

#import "_Media.h"

const struct MediaAttributes MediaAttributes = {
	.cachedData = @"cachedData",
	.foreignKey = @"foreignKey",
	.imagePartial = @"imagePartial",
	.mediaType = @"mediaType",
	.year = @"year",
};

const struct MediaRelationships MediaRelationships = {
	.team = @"team",
};

@implementation MediaID
@end

@implementation _Media

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Media";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Media" inManagedObjectContext:moc_];
}

- (MediaID*)objectID {
	return (MediaID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"mediaTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mediaType"];
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

@dynamic cachedData;

@dynamic foreignKey;

@dynamic imagePartial;

@dynamic mediaType;

- (int64_t)mediaTypeValue {
	NSNumber *result = [self mediaType];
	return [result longLongValue];
}

- (void)setMediaTypeValue:(int64_t)value_ {
	[self setMediaType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMediaTypeValue {
	NSNumber *result = [self primitiveMediaType];
	return [result longLongValue];
}

- (void)setPrimitiveMediaTypeValue:(int64_t)value_ {
	[self setPrimitiveMediaType:[NSNumber numberWithLongLong:value_]];
}

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

@dynamic team;

@end

