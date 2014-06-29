// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.h instead.

#import <CoreData/CoreData.h>


extern const struct MatchAttributes {
	__unsafe_unretained NSString *comp_level;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *match_number;
	__unsafe_unretained NSString *set_number;
	__unsafe_unretained NSString *time_string;
} MatchAttributes;

extern const struct MatchRelationships {
	__unsafe_unretained NSString *blueAlliance;
	__unsafe_unretained NSString *event;
	__unsafe_unretained NSString *media;
	__unsafe_unretained NSString *redAlliance;
} MatchRelationships;

extern const struct MatchFetchedProperties {
} MatchFetchedProperties;

@class Team;
@class Event;
@class Media;
@class Team;







@interface MatchID : NSManagedObjectID {}
@end

@interface _Match : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MatchID*)objectID;





@property (nonatomic, strong) NSString* comp_level;



//- (BOOL)validateComp_level:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* match_number;



@property int32_t match_numberValue;
- (int32_t)match_numberValue;
- (void)setMatch_numberValue:(int32_t)value_;

//- (BOOL)validateMatch_number:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* set_number;



@property int32_t set_numberValue;
- (int32_t)set_numberValue;
- (void)setSet_numberValue:(int32_t)value_;

//- (BOOL)validateSet_number:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* time_string;



//- (BOOL)validateTime_string:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *blueAlliance;

- (NSMutableSet*)blueAllianceSet;




@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *media;

- (NSMutableSet*)mediaSet;




@property (nonatomic, strong) NSSet *redAlliance;

- (NSMutableSet*)redAllianceSet;





@end

@interface _Match (CoreDataGeneratedAccessors)

- (void)addBlueAlliance:(NSSet*)value_;
- (void)removeBlueAlliance:(NSSet*)value_;
- (void)addBlueAllianceObject:(Team*)value_;
- (void)removeBlueAllianceObject:(Team*)value_;

- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

- (void)addRedAlliance:(NSSet*)value_;
- (void)removeRedAlliance:(NSSet*)value_;
- (void)addRedAllianceObject:(Team*)value_;
- (void)removeRedAllianceObject:(Team*)value_;

@end

@interface _Match (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveComp_level;
- (void)setPrimitiveComp_level:(NSString*)value;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSNumber*)primitiveMatch_number;
- (void)setPrimitiveMatch_number:(NSNumber*)value;

- (int32_t)primitiveMatch_numberValue;
- (void)setPrimitiveMatch_numberValue:(int32_t)value_;




- (NSNumber*)primitiveSet_number;
- (void)setPrimitiveSet_number:(NSNumber*)value;

- (int32_t)primitiveSet_numberValue;
- (void)setPrimitiveSet_numberValue:(int32_t)value_;




- (NSString*)primitiveTime_string;
- (void)setPrimitiveTime_string:(NSString*)value;





- (NSMutableSet*)primitiveBlueAlliance;
- (void)setPrimitiveBlueAlliance:(NSMutableSet*)value;



- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;



- (NSMutableSet*)primitiveMedia;
- (void)setPrimitiveMedia:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRedAlliance;
- (void)setPrimitiveRedAlliance:(NSMutableSet*)value;


@end
