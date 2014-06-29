// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.h instead.

#import <CoreData/CoreData.h>


extern const struct EventAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *district_enum;
	__unsafe_unretained NSString *end_date;
	__unsafe_unretained NSString *event_short;
	__unsafe_unretained NSString *event_type;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *last_updated;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *official;
	__unsafe_unretained NSString *rankings;
	__unsafe_unretained NSString *short_name;
	__unsafe_unretained NSString *start_date;
	__unsafe_unretained NSString *stats;
	__unsafe_unretained NSString *timezone;
	__unsafe_unretained NSString *venue;
	__unsafe_unretained NSString *webcasts;
	__unsafe_unretained NSString *website;
	__unsafe_unretained NSString *week;
	__unsafe_unretained NSString *year;
} EventAttributes;

extern const struct EventRelationships {
	__unsafe_unretained NSString *matches;
	__unsafe_unretained NSString *teams;
} EventRelationships;

extern const struct EventFetchedProperties {
} EventFetchedProperties;

@class Match;
@class Team;






















@interface EventID : NSManagedObjectID {}
@end

@interface _Event : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EventID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* district_enum;



@property int32_t district_enumValue;
- (int32_t)district_enumValue;
- (void)setDistrict_enumValue:(int32_t)value_;

//- (BOOL)validateDistrict_enum:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* end_date;



//- (BOOL)validateEnd_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* event_short;



//- (BOOL)validateEvent_short:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* event_type;



@property int32_t event_typeValue;
- (int32_t)event_typeValue;
- (void)setEvent_typeValue:(int32_t)value_;

//- (BOOL)validateEvent_type:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* last_updated;



@property int64_t last_updatedValue;
- (int64_t)last_updatedValue;
- (void)setLast_updatedValue:(int64_t)value_;

//- (BOOL)validateLast_updated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* location;



//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* official;



@property BOOL officialValue;
- (BOOL)officialValue;
- (void)setOfficialValue:(BOOL)value_;

//- (BOOL)validateOfficial:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* rankings;



//- (BOOL)validateRankings:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* short_name;



//- (BOOL)validateShort_name:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* start_date;



//- (BOOL)validateStart_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* stats;



//- (BOOL)validateStats:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* timezone;



//- (BOOL)validateTimezone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* venue;



//- (BOOL)validateVenue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* webcasts;



//- (BOOL)validateWebcasts:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* website;



//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* week;



@property int32_t weekValue;
- (int32_t)weekValue;
- (void)setWeekValue:(int32_t)value_;

//- (BOOL)validateWeek:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* year;



@property int32_t yearValue;
- (int32_t)yearValue;
- (void)setYearValue:(int32_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;




@property (nonatomic, strong) NSSet *teams;

- (NSMutableSet*)teamsSet;





@end

@interface _Event (CoreDataGeneratedAccessors)

- (void)addMatches:(NSSet*)value_;
- (void)removeMatches:(NSSet*)value_;
- (void)addMatchesObject:(Match*)value_;
- (void)removeMatchesObject:(Match*)value_;

- (void)addTeams:(NSSet*)value_;
- (void)removeTeams:(NSSet*)value_;
- (void)addTeamsObject:(Team*)value_;
- (void)removeTeamsObject:(Team*)value_;

@end

@interface _Event (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSNumber*)primitiveDistrict_enum;
- (void)setPrimitiveDistrict_enum:(NSNumber*)value;

- (int32_t)primitiveDistrict_enumValue;
- (void)setPrimitiveDistrict_enumValue:(int32_t)value_;




- (NSDate*)primitiveEnd_date;
- (void)setPrimitiveEnd_date:(NSDate*)value;




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




- (NSString*)primitiveRankings;
- (void)setPrimitiveRankings:(NSString*)value;




- (NSString*)primitiveShort_name;
- (void)setPrimitiveShort_name:(NSString*)value;




- (NSDate*)primitiveStart_date;
- (void)setPrimitiveStart_date:(NSDate*)value;




- (NSString*)primitiveStats;
- (void)setPrimitiveStats:(NSString*)value;




- (NSString*)primitiveTimezone;
- (void)setPrimitiveTimezone:(NSString*)value;




- (NSString*)primitiveVenue;
- (void)setPrimitiveVenue:(NSString*)value;




- (NSString*)primitiveWebcasts;
- (void)setPrimitiveWebcasts:(NSString*)value;




- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;




- (NSNumber*)primitiveWeek;
- (void)setPrimitiveWeek:(NSNumber*)value;

- (int32_t)primitiveWeekValue;
- (void)setPrimitiveWeekValue:(int32_t)value_;




- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int32_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int32_t)value_;





- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTeams;
- (void)setPrimitiveTeams:(NSMutableSet*)value;


@end
