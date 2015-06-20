// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DistrictRanking.h instead.

#import <CoreData/CoreData.h>

extern const struct DistrictRankingAttributes {
	__unsafe_unretained NSString *pointTotal;
	__unsafe_unretained NSString *rank;
	__unsafe_unretained NSString *rookieBonus;
} DistrictRankingAttributes;

extern const struct DistrictRankingRelationships {
	__unsafe_unretained NSString *district;
	__unsafe_unretained NSString *eventPoints;
	__unsafe_unretained NSString *team;
} DistrictRankingRelationships;

@class District;
@class EventPoints;
@class Team;

@interface DistrictRankingID : NSManagedObjectID {}
@end

@interface _DistrictRanking : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DistrictRankingID* objectID;

@property (nonatomic, strong) NSNumber* pointTotal;

@property (atomic) int32_t pointTotalValue;
- (int32_t)pointTotalValue;
- (void)setPointTotalValue:(int32_t)value_;

//- (BOOL)validatePointTotal:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rank;

@property (atomic) int32_t rankValue;
- (int32_t)rankValue;
- (void)setRankValue:(int32_t)value_;

//- (BOOL)validateRank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rookieBonus;

@property (atomic) int32_t rookieBonusValue;
- (int32_t)rookieBonusValue;
- (void)setRookieBonusValue:(int32_t)value_;

//- (BOOL)validateRookieBonus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) District *district;

//- (BOOL)validateDistrict:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *eventPoints;

- (NSMutableSet*)eventPointsSet;

@property (nonatomic, strong) Team *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;

@end

@interface _DistrictRanking (EventPointsCoreDataGeneratedAccessors)
- (void)addEventPoints:(NSSet*)value_;
- (void)removeEventPoints:(NSSet*)value_;
- (void)addEventPointsObject:(EventPoints*)value_;
- (void)removeEventPointsObject:(EventPoints*)value_;

@end

@interface _DistrictRanking (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitivePointTotal;
- (void)setPrimitivePointTotal:(NSNumber*)value;

- (int32_t)primitivePointTotalValue;
- (void)setPrimitivePointTotalValue:(int32_t)value_;

- (NSNumber*)primitiveRank;
- (void)setPrimitiveRank:(NSNumber*)value;

- (int32_t)primitiveRankValue;
- (void)setPrimitiveRankValue:(int32_t)value_;

- (NSNumber*)primitiveRookieBonus;
- (void)setPrimitiveRookieBonus:(NSNumber*)value;

- (int32_t)primitiveRookieBonusValue;
- (void)setPrimitiveRookieBonusValue:(int32_t)value_;

- (District*)primitiveDistrict;
- (void)setPrimitiveDistrict:(District*)value;

- (NSMutableSet*)primitiveEventPoints;
- (void)setPrimitiveEventPoints:(NSMutableSet*)value;

- (Team*)primitiveTeam;
- (void)setPrimitiveTeam:(Team*)value;

@end
