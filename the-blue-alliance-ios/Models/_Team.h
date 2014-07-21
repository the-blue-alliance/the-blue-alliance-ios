// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.h instead.

#import <CoreData/CoreData.h>


extern const struct TeamAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *cachedLocationLat;
	__unsafe_unretained NSString *cachedLocationLon;
	__unsafe_unretained NSString *cachedLocationRadius;
	__unsafe_unretained NSString *grouping_text;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *last_updated;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *nickname;
	__unsafe_unretained NSString *rookieYear;
	__unsafe_unretained NSString *team_number;
	__unsafe_unretained NSString *website;
} TeamAttributes;

extern const struct TeamRelationships {
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *matchesWhereBlue;
	__unsafe_unretained NSString *matchesWhereRed;
	__unsafe_unretained NSString *media;
} TeamRelationships;

extern const struct TeamFetchedProperties {
} TeamFetchedProperties;

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
- (TeamID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cachedLocationLat;



@property double cachedLocationLatValue;
- (double)cachedLocationLatValue;
- (void)setCachedLocationLatValue:(double)value_;

//- (BOOL)validateCachedLocationLat:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cachedLocationLon;



@property double cachedLocationLonValue;
- (double)cachedLocationLonValue;
- (void)setCachedLocationLonValue:(double)value_;

//- (BOOL)validateCachedLocationLon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cachedLocationRadius;



@property double cachedLocationRadiusValue;
- (double)cachedLocationRadiusValue;
- (void)setCachedLocationRadiusValue:(double)value_;

//- (BOOL)validateCachedLocationRadius:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* grouping_text;



//- (BOOL)validateGrouping_text:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* nickname;



//- (BOOL)validateNickname:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rookieYear;



@property int32_t rookieYearValue;
- (int32_t)rookieYearValue;
- (void)setRookieYearValue:(int32_t)value_;

//- (BOOL)validateRookieYear:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* team_number;



@property int32_t team_numberValue;
- (int32_t)team_numberValue;
- (void)setTeam_numberValue:(int32_t)value_;

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

@interface _Team (CoreDataGeneratedAccessors)

- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

- (void)addMatchesWhereBlue:(NSSet*)value_;
- (void)removeMatchesWhereBlue:(NSSet*)value_;
- (void)addMatchesWhereBlueObject:(Match*)value_;
- (void)removeMatchesWhereBlueObject:(Match*)value_;

- (void)addMatchesWhereRed:(NSSet*)value_;
- (void)removeMatchesWhereRed:(NSSet*)value_;
- (void)addMatchesWhereRedObject:(Match*)value_;
- (void)removeMatchesWhereRedObject:(Match*)value_;

- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

@end

@interface _Team (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSNumber*)primitiveCachedLocationLat;
- (void)setPrimitiveCachedLocationLat:(NSNumber*)value;

- (double)primitiveCachedLocationLatValue;
- (void)setPrimitiveCachedLocationLatValue:(double)value_;




- (NSNumber*)primitiveCachedLocationLon;
- (void)setPrimitiveCachedLocationLon:(NSNumber*)value;

- (double)primitiveCachedLocationLonValue;
- (void)setPrimitiveCachedLocationLonValue:(double)value_;




- (NSNumber*)primitiveCachedLocationRadius;
- (void)setPrimitiveCachedLocationRadius:(NSNumber*)value;

- (double)primitiveCachedLocationRadiusValue;
- (void)setPrimitiveCachedLocationRadiusValue:(double)value_;




- (NSString*)primitiveGrouping_text;
- (void)setPrimitiveGrouping_text:(NSString*)value;




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




- (NSString*)primitiveNickname;
- (void)setPrimitiveNickname:(NSString*)value;




- (NSNumber*)primitiveRookieYear;
- (void)setPrimitiveRookieYear:(NSNumber*)value;

- (int32_t)primitiveRookieYearValue;
- (void)setPrimitiveRookieYearValue:(int32_t)value_;




- (NSNumber*)primitiveTeam_number;
- (void)setPrimitiveTeam_number:(NSNumber*)value;

- (int32_t)primitiveTeam_numberValue;
- (void)setPrimitiveTeam_numberValue:(int32_t)value_;




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
