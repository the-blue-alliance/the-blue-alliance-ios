// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.h instead.

#import <CoreData/CoreData.h>


extern const struct MediaAttributes {
	__unsafe_unretained NSString *cachedData;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *url;
} MediaAttributes;

extern const struct MediaRelationships {
} MediaRelationships;

extern const struct MediaFetchedProperties {
} MediaFetchedProperties;







@interface MediaID : NSManagedObjectID {}
@end

@interface _Media : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MediaID*)objectID;





@property (nonatomic, strong) NSData* cachedData;



//- (BOOL)validateCachedData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;






@end

@interface _Media (CoreDataGeneratedAccessors)

@end

@interface _Media (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveCachedData;
- (void)setPrimitiveCachedData:(NSData*)value;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;




@end
