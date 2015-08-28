// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MatchVideo.m instead.

#import "_MatchVideo.h"

const struct MatchVideoAttributes MatchVideoAttributes = {
	.key = @"key",
	.videoType = @"videoType",
};

const struct MatchVideoRelationships MatchVideoRelationships = {
	.match = @"match",
};

@implementation MatchVideoID
@end

@implementation _MatchVideo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MatchVideo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MatchVideo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MatchVideo" inManagedObjectContext:moc_];
}

- (MatchVideoID*)objectID {
	return (MatchVideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"videoTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic key;

@dynamic videoType;

- (int64_t)videoTypeValue {
	NSNumber *result = [self videoType];
	return [result longLongValue];
}

- (void)setVideoTypeValue:(int64_t)value_ {
	[self setVideoType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveVideoTypeValue {
	NSNumber *result = [self primitiveVideoType];
	return [result longLongValue];
}

- (void)setPrimitiveVideoTypeValue:(int64_t)value_ {
	[self setPrimitiveVideoType:[NSNumber numberWithLongLong:value_]];
}

@dynamic match;

@end

