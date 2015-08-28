// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MatchAlliance.h instead.

#import <CoreData/CoreData.h>

extern const struct MatchAllianceAttributes {
	__unsafe_unretained NSString *score;
	__unsafe_unretained NSString *teams;
} MatchAllianceAttributes;

@class NSObject;

@interface MatchAllianceID : NSManagedObjectID {}
@end

@interface _MatchAlliance : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MatchAllianceID* objectID;

@property (nonatomic, strong) NSNumber* score;

@property (atomic) int64_t scoreValue;
- (int64_t)scoreValue;
- (void)setScoreValue:(int64_t)value_;

//- (BOOL)validateScore:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id teams;

//- (BOOL)validateTeams:(id*)value_ error:(NSError**)error_;

@end

@interface _MatchAlliance (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveScore;
- (void)setPrimitiveScore:(NSNumber*)value;

- (int64_t)primitiveScoreValue;
- (void)setPrimitiveScoreValue:(int64_t)value_;

- (id)primitiveTeams;
- (void)setPrimitiveTeams:(id)value;

@end
