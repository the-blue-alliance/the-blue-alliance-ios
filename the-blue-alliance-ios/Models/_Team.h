// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.h instead.

#import <CoreData/CoreData.h>

extern const struct TeamAttributes {
	__unsafe_unretained NSString *countryName;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *locality;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *nickname;
	__unsafe_unretained NSString *region;
	__unsafe_unretained NSString *rookieYear;
	__unsafe_unretained NSString *teamNumber;
	__unsafe_unretained NSString *website;
	__unsafe_unretained NSString *yearsParticipated;
} TeamAttributes;

extern const struct TeamRelationships {
	__unsafe_unretained NSString *districtRankings;
	__unsafe_unretained NSString *eventPoints;
	__unsafe_unretained NSString *eventRankings;
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *media;
} TeamRelationships;

@class DistrictRanking;
@class EventPoints;
@class EventRanking;
@class Event;
@class Media;

@class NSObject;

@interface TeamID : NSManagedObjectID {}
@end

@interface _Team : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TeamID* objectID;

@property (nonatomic, strong) NSString* countryName;

//- (BOOL)validateCountryName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* locality;

//- (BOOL)validateLocality:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* nickname;

//- (BOOL)validateNickname:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* region;

//- (BOOL)validateRegion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rookieYear;

@property (atomic) int64_t rookieYearValue;
- (int64_t)rookieYearValue;
- (void)setRookieYearValue:(int64_t)value_;

//- (BOOL)validateRookieYear:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* teamNumber;

@property (atomic) uint64_t teamNumberValue;
- (uint64_t)teamNumberValue;
- (void)setTeamNumberValue:(uint64_t)value_;

//- (BOOL)validateTeamNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* website;

//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id yearsParticipated;

//- (BOOL)validateYearsParticipated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *districtRankings;

- (NSMutableSet*)districtRankingsSet;

@property (nonatomic, strong) NSSet *eventPoints;

- (NSMutableSet*)eventPointsSet;

@property (nonatomic, strong) NSSet *eventRankings;

- (NSMutableSet*)eventRankingsSet;

@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;

@property (nonatomic, strong) NSSet *media;

- (NSMutableSet*)mediaSet;

@end

@interface _Team (DistrictRankingsCoreDataGeneratedAccessors)
- (void)addDistrictRankings:(NSSet*)value_;
- (void)removeDistrictRankings:(NSSet*)value_;
- (void)addDistrictRankingsObject:(DistrictRanking*)value_;
- (void)removeDistrictRankingsObject:(DistrictRanking*)value_;

@end

@interface _Team (EventPointsCoreDataGeneratedAccessors)
- (void)addEventPoints:(NSSet*)value_;
- (void)removeEventPoints:(NSSet*)value_;
- (void)addEventPointsObject:(EventPoints*)value_;
- (void)removeEventPointsObject:(EventPoints*)value_;

@end

@interface _Team (EventRankingsCoreDataGeneratedAccessors)
- (void)addEventRankings:(NSSet*)value_;
- (void)removeEventRankings:(NSSet*)value_;
- (void)addEventRankingsObject:(EventRanking*)value_;
- (void)removeEventRankingsObject:(EventRanking*)value_;

@end

@interface _Team (EventsCoreDataGeneratedAccessors)
- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

@end

@interface _Team (MediaCoreDataGeneratedAccessors)
- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

@end

@interface _Team (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCountryName;
- (void)setPrimitiveCountryName:(NSString*)value;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSString*)primitiveLocality;
- (void)setPrimitiveLocality:(NSString*)value;

- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveNickname;
- (void)setPrimitiveNickname:(NSString*)value;

- (NSString*)primitiveRegion;
- (void)setPrimitiveRegion:(NSString*)value;

- (NSNumber*)primitiveRookieYear;
- (void)setPrimitiveRookieYear:(NSNumber*)value;

- (int64_t)primitiveRookieYearValue;
- (void)setPrimitiveRookieYearValue:(int64_t)value_;

- (NSNumber*)primitiveTeamNumber;
- (void)setPrimitiveTeamNumber:(NSNumber*)value;

- (uint64_t)primitiveTeamNumberValue;
- (void)setPrimitiveTeamNumberValue:(uint64_t)value_;

- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;

- (id)primitiveYearsParticipated;
- (void)setPrimitiveYearsParticipated:(id)value;

- (NSMutableSet*)primitiveDistrictRankings;
- (void)setPrimitiveDistrictRankings:(NSMutableSet*)value;

- (NSMutableSet*)primitiveEventPoints;
- (void)setPrimitiveEventPoints:(NSMutableSet*)value;

- (NSMutableSet*)primitiveEventRankings;
- (void)setPrimitiveEventRankings:(NSMutableSet*)value;

- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMedia;
- (void)setPrimitiveMedia:(NSMutableSet*)value;

@end
