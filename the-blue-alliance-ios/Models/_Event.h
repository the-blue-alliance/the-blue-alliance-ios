// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.h instead.

#import <CoreData/CoreData.h>

extern const struct EventAttributes {
	__unsafe_unretained NSString *endDate;
	__unsafe_unretained NSString *eventCode;
	__unsafe_unretained NSString *eventDistrict;
	__unsafe_unretained NSString *eventType;
	__unsafe_unretained NSString *facebookEid;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *official;
	__unsafe_unretained NSString *shortName;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *venueAddress;
	__unsafe_unretained NSString *website;
	__unsafe_unretained NSString *year;
} EventAttributes;

extern const struct EventRelationships {
	__unsafe_unretained NSString *alliances;
	__unsafe_unretained NSString *points;
	__unsafe_unretained NSString *rankings;
	__unsafe_unretained NSString *teams;
	__unsafe_unretained NSString *webcasts;
} EventRelationships;

@class EventAlliance;
@class EventPoints;
@class EventRanking;
@class Team;
@class EventWebcast;

@interface EventID : NSManagedObjectID {}
@end

@interface _Event : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventID* objectID;

@property (nonatomic, strong) NSDate* endDate;

//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* eventCode;

//- (BOOL)validateEventCode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* eventDistrict;

//- (BOOL)validateEventDistrict:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* eventType;

@property (atomic) int32_t eventTypeValue;
- (int32_t)eventTypeValue;
- (void)setEventTypeValue:(int32_t)value_;

//- (BOOL)validateEventType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* facebookEid;

//- (BOOL)validateFacebookEid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* official;

@property (atomic) BOOL officialValue;
- (BOOL)officialValue;
- (void)setOfficialValue:(BOOL)value_;

//- (BOOL)validateOfficial:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* shortName;

//- (BOOL)validateShortName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* startDate;

//- (BOOL)validateStartDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* venueAddress;

//- (BOOL)validateVenueAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* website;

//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* year;

@property (atomic) int64_t yearValue;
- (int64_t)yearValue;
- (void)setYearValue:(int64_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *alliances;

- (NSMutableSet*)alliancesSet;

@property (nonatomic, strong) NSSet *points;

- (NSMutableSet*)pointsSet;

@property (nonatomic, strong) NSSet *rankings;

- (NSMutableSet*)rankingsSet;

@property (nonatomic, strong) NSSet *teams;

- (NSMutableSet*)teamsSet;

@property (nonatomic, strong) NSSet *webcasts;

- (NSMutableSet*)webcastsSet;

@end

@interface _Event (AlliancesCoreDataGeneratedAccessors)
- (void)addAlliances:(NSSet*)value_;
- (void)removeAlliances:(NSSet*)value_;
- (void)addAlliancesObject:(EventAlliance*)value_;
- (void)removeAlliancesObject:(EventAlliance*)value_;

@end

@interface _Event (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(EventPoints*)value_;
- (void)removePointsObject:(EventPoints*)value_;

@end

@interface _Event (RankingsCoreDataGeneratedAccessors)
- (void)addRankings:(NSSet*)value_;
- (void)removeRankings:(NSSet*)value_;
- (void)addRankingsObject:(EventRanking*)value_;
- (void)removeRankingsObject:(EventRanking*)value_;

@end

@interface _Event (TeamsCoreDataGeneratedAccessors)
- (void)addTeams:(NSSet*)value_;
- (void)removeTeams:(NSSet*)value_;
- (void)addTeamsObject:(Team*)value_;
- (void)removeTeamsObject:(Team*)value_;

@end

@interface _Event (WebcastsCoreDataGeneratedAccessors)
- (void)addWebcasts:(NSSet*)value_;
- (void)removeWebcasts:(NSSet*)value_;
- (void)addWebcastsObject:(EventWebcast*)value_;
- (void)removeWebcastsObject:(EventWebcast*)value_;

@end

@interface _Event (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;

- (NSString*)primitiveEventCode;
- (void)setPrimitiveEventCode:(NSString*)value;

- (NSString*)primitiveEventDistrict;
- (void)setPrimitiveEventDistrict:(NSString*)value;

- (NSNumber*)primitiveEventType;
- (void)setPrimitiveEventType:(NSNumber*)value;

- (int32_t)primitiveEventTypeValue;
- (void)setPrimitiveEventTypeValue:(int32_t)value_;

- (NSString*)primitiveFacebookEid;
- (void)setPrimitiveFacebookEid:(NSString*)value;

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveOfficial;
- (void)setPrimitiveOfficial:(NSNumber*)value;

- (BOOL)primitiveOfficialValue;
- (void)setPrimitiveOfficialValue:(BOOL)value_;

- (NSString*)primitiveShortName;
- (void)setPrimitiveShortName:(NSString*)value;

- (NSDate*)primitiveStartDate;
- (void)setPrimitiveStartDate:(NSDate*)value;

- (NSString*)primitiveVenueAddress;
- (void)setPrimitiveVenueAddress:(NSString*)value;

- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;

- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int64_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int64_t)value_;

- (NSMutableSet*)primitiveAlliances;
- (void)setPrimitiveAlliances:(NSMutableSet*)value;

- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;

- (NSMutableSet*)primitiveRankings;
- (void)setPrimitiveRankings:(NSMutableSet*)value;

- (NSMutableSet*)primitiveTeams;
- (void)setPrimitiveTeams:(NSMutableSet*)value;

- (NSMutableSet*)primitiveWebcasts;
- (void)setPrimitiveWebcasts:(NSMutableSet*)value;

@end
