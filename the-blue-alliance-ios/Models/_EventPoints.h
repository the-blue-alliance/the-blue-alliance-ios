// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventPoints.h instead.

#import <CoreData/CoreData.h>

extern const struct EventPointsAttributes {
	__unsafe_unretained NSString *alliancePoints;
	__unsafe_unretained NSString *awardPoints;
	__unsafe_unretained NSString *districtCMP;
	__unsafe_unretained NSString *elimPoints;
	__unsafe_unretained NSString *qualPoints;
	__unsafe_unretained NSString *total;
} EventPointsAttributes;

extern const struct EventPointsRelationships {
	__unsafe_unretained NSString *districtRanking;
	__unsafe_unretained NSString *event;
	__unsafe_unretained NSString *team;
} EventPointsRelationships;

@class DistrictRanking;
@class Event;
@class Team;

@interface EventPointsID : NSManagedObjectID {}
@end

@interface _EventPoints : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventPointsID* objectID;

@property (nonatomic, strong) NSNumber* alliancePoints;

@property (atomic) int64_t alliancePointsValue;
- (int64_t)alliancePointsValue;
- (void)setAlliancePointsValue:(int64_t)value_;

//- (BOOL)validateAlliancePoints:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* awardPoints;

@property (atomic) int64_t awardPointsValue;
- (int64_t)awardPointsValue;
- (void)setAwardPointsValue:(int64_t)value_;

//- (BOOL)validateAwardPoints:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* districtCMP;

@property (atomic) BOOL districtCMPValue;
- (BOOL)districtCMPValue;
- (void)setDistrictCMPValue:(BOOL)value_;

//- (BOOL)validateDistrictCMP:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* elimPoints;

@property (atomic) int64_t elimPointsValue;
- (int64_t)elimPointsValue;
- (void)setElimPointsValue:(int64_t)value_;

//- (BOOL)validateElimPoints:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* qualPoints;

@property (atomic) int64_t qualPointsValue;
- (int64_t)qualPointsValue;
- (void)setQualPointsValue:(int64_t)value_;

//- (BOOL)validateQualPoints:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* total;

@property (atomic) int64_t totalValue;
- (int64_t)totalValue;
- (void)setTotalValue:(int64_t)value_;

//- (BOOL)validateTotal:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) DistrictRanking *districtRanking;

//- (BOOL)validateDistrictRanking:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Team *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;

@end

@interface _EventPoints (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAlliancePoints;
- (void)setPrimitiveAlliancePoints:(NSNumber*)value;

- (int64_t)primitiveAlliancePointsValue;
- (void)setPrimitiveAlliancePointsValue:(int64_t)value_;

- (NSNumber*)primitiveAwardPoints;
- (void)setPrimitiveAwardPoints:(NSNumber*)value;

- (int64_t)primitiveAwardPointsValue;
- (void)setPrimitiveAwardPointsValue:(int64_t)value_;

- (NSNumber*)primitiveDistrictCMP;
- (void)setPrimitiveDistrictCMP:(NSNumber*)value;

- (BOOL)primitiveDistrictCMPValue;
- (void)setPrimitiveDistrictCMPValue:(BOOL)value_;

- (NSNumber*)primitiveElimPoints;
- (void)setPrimitiveElimPoints:(NSNumber*)value;

- (int64_t)primitiveElimPointsValue;
- (void)setPrimitiveElimPointsValue:(int64_t)value_;

- (NSNumber*)primitiveQualPoints;
- (void)setPrimitiveQualPoints:(NSNumber*)value;

- (int64_t)primitiveQualPointsValue;
- (void)setPrimitiveQualPointsValue:(int64_t)value_;

- (NSNumber*)primitiveTotal;
- (void)setPrimitiveTotal:(NSNumber*)value;

- (int64_t)primitiveTotalValue;
- (void)setPrimitiveTotalValue:(int64_t)value_;

- (DistrictRanking*)primitiveDistrictRanking;
- (void)setPrimitiveDistrictRanking:(DistrictRanking*)value;

- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;

- (Team*)primitiveTeam;
- (void)setPrimitiveTeam:(Team*)value;

@end
