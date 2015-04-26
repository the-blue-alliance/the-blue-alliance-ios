// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.h instead.

#import <CoreData/CoreData.h>

extern const struct TeamAttributes {
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *grouping_text;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *last_updated;
	__unsafe_unretained NSString *locality;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *nickname;
	__unsafe_unretained NSString *region;
	__unsafe_unretained NSString *rookie_year;
	__unsafe_unretained NSString *team_number;
	__unsafe_unretained NSString *website;
} TeamAttributes;

extern const struct TeamRelationships {
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *matchesWhereBlue;
	__unsafe_unretained NSString *matchesWhereRed;
	__unsafe_unretained NSString *media;
} TeamRelationships;

@class Event;
@class Match;
@class Match;
@class Media;

@interface TeamID : NSManagedObjectID {}
@end

@interface _Team : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TeamID* objectID;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* grouping_text;

//- (BOOL)validateGrouping_text:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* last_updated;

@property (atomic) int64_t last_updatedValue;
- (int64_t)last_updatedValue;
- (void)setLast_updatedValue:(int64_t)value_;

//- (BOOL)validateLast_updated:(id*)value_ error:(NSError**)error_;

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

@property (nonatomic, strong) NSNumber* rookie_year;

@property (atomic) int32_t rookie_yearValue;
- (int32_t)rookie_yearValue;
- (void)setRookie_yearValue:(int32_t)value_;

//- (BOOL)validateRookie_year:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* team_number;

@property (atomic) uint32_t team_numberValue;
- (uint32_t)team_numberValue;
- (void)setTeam_numberValue:(uint32_t)value_;

//- (BOOL)validateTeam_number:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* website;

//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;

@property (nonatomic, strong) NSSet *matchesWhereBlue;

- (NSMutableSet*)matchesWhereBlueSet;

@property (nonatomic, strong) NSSet *matchesWhereRed;

- (NSMutableSet*)matchesWhereRedSet;

@property (nonatomic, strong) NSSet *media;

- (NSMutableSet*)mediaSet;

@end

@interface _Team (EventsCoreDataGeneratedAccessors)
- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

@end

@interface _Team (MatchesWhereBlueCoreDataGeneratedAccessors)
- (void)addMatchesWhereBlue:(NSSet*)value_;
- (void)removeMatchesWhereBlue:(NSSet*)value_;
- (void)addMatchesWhereBlueObject:(Match*)value_;
- (void)removeMatchesWhereBlueObject:(Match*)value_;

@end

@interface _Team (MatchesWhereRedCoreDataGeneratedAccessors)
- (void)addMatchesWhereRed:(NSSet*)value_;
- (void)removeMatchesWhereRed:(NSSet*)value_;
- (void)addMatchesWhereRedObject:(Match*)value_;
- (void)removeMatchesWhereRedObject:(Match*)value_;

@end

@interface _Team (MediaCoreDataGeneratedAccessors)
- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

@end

@interface _Team (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;

- (NSString*)primitiveGrouping_text;
- (void)setPrimitiveGrouping_text:(NSString*)value;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSNumber*)primitiveLast_updated;
- (void)setPrimitiveLast_updated:(NSNumber*)value;

- (int64_t)primitiveLast_updatedValue;
- (void)setPrimitiveLast_updatedValue:(int64_t)value_;

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

- (NSNumber*)primitiveRookie_year;
- (void)setPrimitiveRookie_year:(NSNumber*)value;

- (int32_t)primitiveRookie_yearValue;
- (void)setPrimitiveRookie_yearValue:(int32_t)value_;

- (NSNumber*)primitiveTeam_number;
- (void)setPrimitiveTeam_number:(NSNumber*)value;

- (uint32_t)primitiveTeam_numberValue;
- (void)setPrimitiveTeam_numberValue:(uint32_t)value_;

- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;

- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMatchesWhereBlue;
- (void)setPrimitiveMatchesWhereBlue:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMatchesWhereRed;
- (void)setPrimitiveMatchesWhereRed:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMedia;
- (void)setPrimitiveMedia:(NSMutableSet*)value;

@end
