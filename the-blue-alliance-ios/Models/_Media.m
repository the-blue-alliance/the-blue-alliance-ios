// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.m instead.

#import "_Media.h"

const struct MediaAttributes MediaAttributes = {
	.type = @"type",
	.url = @"url",
};

const struct MediaRelationships MediaRelationships = {
};

const struct MediaFetchedProperties MediaFetchedProperties = {
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
	

	return keyPaths;
}




@dynamic type;






@dynamic url;











@end
