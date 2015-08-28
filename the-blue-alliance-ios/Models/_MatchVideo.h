// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MatchVideo.h instead.

#import <CoreData/CoreData.h>

extern const struct MatchVideoAttributes {
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *videoType;
} MatchVideoAttributes;

extern const struct MatchVideoRelationships {
	__unsafe_unretained NSString *match;
} MatchVideoRelationships;

@class Match;

@interface MatchVideoID : NSManagedObjectID {}
@end

@interface _MatchVideo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MatchVideoID* objectID;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* videoType;

@property (atomic) int64_t videoTypeValue;
- (int64_t)videoTypeValue;
- (void)setVideoTypeValue:(int64_t)value_;

//- (BOOL)validateVideoType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Match *match;

//- (BOOL)validateMatch:(id*)value_ error:(NSError**)error_;

@end

@interface _MatchVideo (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSNumber*)primitiveVideoType;
- (void)setPrimitiveVideoType:(NSNumber*)value;

- (int64_t)primitiveVideoTypeValue;
- (void)setPrimitiveVideoTypeValue:(int64_t)value_;

- (Match*)primitiveMatch;
- (void)setPrimitiveMatch:(Match*)value;

@end
