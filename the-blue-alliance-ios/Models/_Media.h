// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.h instead.

#import <CoreData/CoreData.h>

extern const struct MediaAttributes {
	__unsafe_unretained NSString *cachedData;
	__unsafe_unretained NSString *foreignKey;
	__unsafe_unretained NSString *imagePartial;
	__unsafe_unretained NSString *mediaType;
	__unsafe_unretained NSString *year;
} MediaAttributes;

extern const struct MediaRelationships {
	__unsafe_unretained NSString *team;
} MediaRelationships;

@class Team;

@class NSObject;

@interface MediaID : NSManagedObjectID {}
@end

@interface _Media : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MediaID* objectID;

@property (nonatomic, strong) id cachedData;

//- (BOOL)validateCachedData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* foreignKey;

//- (BOOL)validateForeignKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* imagePartial;

//- (BOOL)validateImagePartial:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mediaType;

@property (atomic) int64_t mediaTypeValue;
- (int64_t)mediaTypeValue;
- (void)setMediaTypeValue:(int64_t)value_;

//- (BOOL)validateMediaType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* year;

@property (atomic) int64_t yearValue;
- (int64_t)yearValue;
- (void)setYearValue:(int64_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Team *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;

@end

@interface _Media (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveCachedData;
- (void)setPrimitiveCachedData:(id)value;

- (NSString*)primitiveForeignKey;
- (void)setPrimitiveForeignKey:(NSString*)value;

- (NSString*)primitiveImagePartial;
- (void)setPrimitiveImagePartial:(NSString*)value;

- (NSNumber*)primitiveMediaType;
- (void)setPrimitiveMediaType:(NSNumber*)value;

- (int64_t)primitiveMediaTypeValue;
- (void)setPrimitiveMediaTypeValue:(int64_t)value_;

- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int64_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int64_t)value_;

- (Team*)primitiveTeam;
- (void)setPrimitiveTeam:(Team*)value;

@end
