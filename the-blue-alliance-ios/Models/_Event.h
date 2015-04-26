// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.h instead.

#import <CoreData/CoreData.h>

extern const struct EventAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *alliances;
	__unsafe_unretained NSString *district_points;
	__unsafe_unretained NSString *end_date;
	__unsafe_unretained NSString *event_district;
	__unsafe_unretained NSString *event_short;
	__unsafe_unretained NSString *event_type;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *last_updated;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *official;
	__unsafe_unretained NSString *short_name;
	__unsafe_unretained NSString *start_date;
	__unsafe_unretained NSString *venue;
	__unsafe_unretained NSString *website;
	__unsafe_unretained NSString *year;
} EventAttributes;

extern const struct EventRelationships {
	__unsafe_unretained NSString *matches;
	__unsafe_unretained NSString *media;
	__unsafe_unretained NSString *teams;
} EventRelationships;

@class Match;
@class Media;
@class Team;

@class NSObject;

@class NSObject;

@interface EventID : NSManagedObjectID {}
@end

@interface _Event : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventID* objectID;

@property (nonatomic, strong) NSString* address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id alliances;

//- (BOOL)validateAlliances:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id district_points;

//- (BOOL)validateDistrict_points:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* end_date;

//- (BOOL)validateEnd_date:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* event_district;

@property (atomic) int32_t event_districtValue;
- (int32_t)event_districtValue;
- (void)setEvent_districtValue:(int32_t)value_;

//- (BOOL)validateEvent_district:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* event_short;

//- (BOOL)validateEvent_short:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* event_type;

@property (atomic) int32_t event_typeValue;
- (int32_t)event_typeValue;
- (void)setEvent_typeValue:(int32_t)value_;

//- (BOOL)validateEvent_type:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* last_updated;

@property (atomic) int64_t last_updatedValue;
- (int64_t)last_updatedValue;
- (void)setLast_updatedValue:(int64_t)value_;

//- (BOOL)validateLast_updated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* official;

@property (atomic) BOOL officialValue;
- (BOOL)officialValue;
- (void)setOfficialValue:(BOOL)value_;

//- (BOOL)validateOfficial:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* short_name;

//- (BOOL)validateShort_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* start_date;

//- (BOOL)validateStart_date:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* venue;

//- (BOOL)validateVenue:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* website;

//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* year;

@property (atomic) int32_t yearValue;
- (int32_t)yearValue;
- (void)setYearValue:(int32_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;

@property (nonatomic, strong) NSSet *media;

- (NSMutableSet*)mediaSet;

@property (nonatomic, strong) NSSet *teams;

- (NSMutableSet*)teamsSet;

@end

@interface _Event (MatchesCoreDataGeneratedAccessors)
- (void)addMatches:(NSSet*)value_;
- (void)removeMatches:(NSSet*)value_;
- (void)addMatchesObject:(Match*)value_;
- (void)removeMatchesObject:(Match*)value_;

@end

@interface _Event (MediaCoreDataGeneratedAccessors)
- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

@end

@interface _Event (TeamsCoreDataGeneratedAccessors)
- (void)addTeams:(NSSet*)value_;
- (void)removeTeams:(NSSet*)value_;
- (void)addTeamsObject:(Team*)value_;
- (void)removeTeamsObject:(Team*)value_;

@end

@interface _Event (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;

- (id)primitiveAlliances;
- (void)setPrimitiveAlliances:(id)value;

- (id)primitiveDistrict_points;
- (void)setPrimitiveDistrict_points:(id)value;

- (NSDate*)primitiveEnd_date;
- (void)setPrimitiveEnd_date:(NSDate*)value;

- (NSNumber*)primitiveEvent_district;
- (void)setPrimitiveEvent_district:(NSNumber*)value;

- (int32_t)primitiveEvent_districtValue;
- (void)setPrimitiveEvent_districtValue:(int32_t)value_;

- (NSString*)primitiveEvent_short;
- (void)setPrimitiveEvent_short:(NSString*)value;

- (NSNumber*)primitiveEvent_type;
- (void)setPrimitiveEvent_type:(NSNumber*)value;

- (int32_t)primitiveEvent_typeValue;
- (void)setPrimitiveEvent_typeValue:(int32_t)value_;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSNumber*)primitiveLast_updated;
- (void)setPrimitiveLast_updated:(NSNumber*)value;

- (int64_t)primitiveLast_updatedValue;
- (void)setPrimitiveLast_updatedValue:(int64_t)value_;

- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveOfficial;
- (void)setPrimitiveOfficial:(NSNumber*)value;

- (BOOL)primitiveOfficialValue;
- (void)setPrimitiveOfficialValue:(BOOL)value_;

- (NSString*)primitiveShort_name;
- (void)setPrimitiveShort_name:(NSString*)value;

- (NSDate*)primitiveStart_date;
- (void)setPrimitiveStart_date:(NSDate*)value;

- (NSString*)primitiveVenue;
- (void)setPrimitiveVenue:(NSString*)value;

- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;

- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int32_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int32_t)value_;

- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMedia;
- (void)setPrimitiveMedia:(NSMutableSet*)value;

- (NSMutableSet*)primitiveTeams;
- (void)setPrimitiveTeams:(NSMutableSet*)value;

@end
