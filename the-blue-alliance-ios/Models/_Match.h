// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.h instead.

#import <CoreData/CoreData.h>

extern const struct MatchAttributes {
	__unsafe_unretained NSString *blueAlliance;
	__unsafe_unretained NSString *blueScore;
	__unsafe_unretained NSString *compLevel;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *matchNumber;
	__unsafe_unretained NSString *redAlliance;
	__unsafe_unretained NSString *redScore;
	__unsafe_unretained NSString *scoreBreakdown;
	__unsafe_unretained NSString *setNumber;
	__unsafe_unretained NSString *time;
} MatchAttributes;

extern const struct MatchRelationships {
	__unsafe_unretained NSString *event;
	__unsafe_unretained NSString *vidoes;
} MatchRelationships;

@class Event;
@class MatchVideo;

@class NSObject;

@class NSObject;

@class NSObject;

@interface MatchID : NSManagedObjectID {}
@end

@interface _Match : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MatchID* objectID;

@property (nonatomic, strong) id blueAlliance;

//- (BOOL)validateBlueAlliance:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* blueScore;

@property (atomic) int64_t blueScoreValue;
- (int64_t)blueScoreValue;
- (void)setBlueScoreValue:(int64_t)value_;

//- (BOOL)validateBlueScore:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* compLevel;

@property (atomic) int64_t compLevelValue;
- (int64_t)compLevelValue;
- (void)setCompLevelValue:(int64_t)value_;

//- (BOOL)validateCompLevel:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* matchNumber;

@property (atomic) int64_t matchNumberValue;
- (int64_t)matchNumberValue;
- (void)setMatchNumberValue:(int64_t)value_;

//- (BOOL)validateMatchNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id redAlliance;

//- (BOOL)validateRedAlliance:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* redScore;

@property (atomic) int64_t redScoreValue;
- (int64_t)redScoreValue;
- (void)setRedScoreValue:(int64_t)value_;

//- (BOOL)validateRedScore:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id scoreBreakdown;

//- (BOOL)validateScoreBreakdown:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* setNumber;

@property (atomic) int64_t setNumberValue;
- (int64_t)setNumberValue;
- (void)setSetNumberValue:(int64_t)value_;

//- (BOOL)validateSetNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* time;

//- (BOOL)validateTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *vidoes;

- (NSMutableSet*)vidoesSet;

@end

@interface _Match (VidoesCoreDataGeneratedAccessors)
- (void)addVidoes:(NSSet*)value_;
- (void)removeVidoes:(NSSet*)value_;
- (void)addVidoesObject:(MatchVideo*)value_;
- (void)removeVidoesObject:(MatchVideo*)value_;

@end

@interface _Match (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveBlueAlliance;
- (void)setPrimitiveBlueAlliance:(id)value;

- (NSNumber*)primitiveBlueScore;
- (void)setPrimitiveBlueScore:(NSNumber*)value;

- (int64_t)primitiveBlueScoreValue;
- (void)setPrimitiveBlueScoreValue:(int64_t)value_;

- (NSNumber*)primitiveCompLevel;
- (void)setPrimitiveCompLevel:(NSNumber*)value;

- (int64_t)primitiveCompLevelValue;
- (void)setPrimitiveCompLevelValue:(int64_t)value_;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSNumber*)primitiveMatchNumber;
- (void)setPrimitiveMatchNumber:(NSNumber*)value;

- (int64_t)primitiveMatchNumberValue;
- (void)setPrimitiveMatchNumberValue:(int64_t)value_;

- (id)primitiveRedAlliance;
- (void)setPrimitiveRedAlliance:(id)value;

- (NSNumber*)primitiveRedScore;
- (void)setPrimitiveRedScore:(NSNumber*)value;

- (int64_t)primitiveRedScoreValue;
- (void)setPrimitiveRedScoreValue:(int64_t)value_;

- (id)primitiveScoreBreakdown;
- (void)setPrimitiveScoreBreakdown:(id)value;

- (NSNumber*)primitiveSetNumber;
- (void)setPrimitiveSetNumber:(NSNumber*)value;

- (int64_t)primitiveSetNumberValue;
- (void)setPrimitiveSetNumberValue:(int64_t)value_;

- (NSDate*)primitiveTime;
- (void)setPrimitiveTime:(NSDate*)value;

- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;

- (NSMutableSet*)primitiveVidoes;
- (void)setPrimitiveVidoes:(NSMutableSet*)value;

@end
