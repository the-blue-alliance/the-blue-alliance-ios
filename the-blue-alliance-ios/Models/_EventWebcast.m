// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventWebcast.m instead.

#import "_EventWebcast.h"

const struct EventWebcastAttributes EventWebcastAttributes = {
	.channel = @"channel",
	.file = @"file",
	.webcastType = @"webcastType",
};

const struct EventWebcastRelationships EventWebcastRelationships = {
	.event = @"event",
};

@implementation EventWebcastID
@end

@implementation _EventWebcast

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EventWebcast" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EventWebcast";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EventWebcast" inManagedObjectContext:moc_];
}

- (EventWebcastID*)objectID {
	return (EventWebcastID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"webcastTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"webcastType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic channel;

@dynamic file;

@dynamic webcastType;

- (int64_t)webcastTypeValue {
	NSNumber *result = [self webcastType];
	return [result longLongValue];
}

- (void)setWebcastTypeValue:(int64_t)value_ {
	[self setWebcastType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveWebcastTypeValue {
	NSNumber *result = [self primitiveWebcastType];
	return [result longLongValue];
}

- (void)setPrimitiveWebcastTypeValue:(int64_t)value_ {
	[self setPrimitiveWebcastType:[NSNumber numberWithLongLong:value_]];
}

@dynamic event;

@end

