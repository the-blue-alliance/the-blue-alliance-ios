// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.h instead.

#import <CoreData/CoreData.h>


extern const struct MatchAttributes {
	__unsafe_unretained NSString *blueScore;
	__unsafe_unretained NSString *comp_level;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *match_number;
	__unsafe_unretained NSString *redScore;
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





@property (nonatomic, strong) NSNumber* blueScore;



@property int32_t blueScoreValue;
- (int32_t)blueScoreValue;
- (void)setBlueScoreValue:(int32_t)value_;

//- (BOOL)validateBlueScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* comp_level;



//- (BOOL)validateComp_level:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* match_number;



@property int32_t match_numberValue;
- (int32_t)match_numberValue;
- (void)setMatch_numberValue:(int32_t)value_;

//- (BOOL)validateMatch_number:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* redScore;



@property int32_t redScoreValue;
- (int32_t)redScoreValue;
- (void)setRedScoreValue:(int32_t)value_;

//- (BOOL)validateRedScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* set_number;



@property int32_t set_numberValue;
- (int32_t)set_numberValue;
- (void)setSet_numberValue:(int32_t)value_;

//- (BOOL)validateSet_number:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* time_string;



//- (BOOL)validateTime_string:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *blueAlliance;

- (NSMutableOrderedSet*)blueAllianceSet;




@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *media;

- (NSMutableSet*)mediaSet;




@property (nonatomic, strong) NSOrderedSet *redAlliance;

- (NSMutableOrderedSet*)redAllianceSet;





@end

@interface _Match (CoreDataGeneratedAccessors)

- (void)addBlueAlliance:(NSOrderedSet*)value_;
- (void)removeBlueAlliance:(NSOrderedSet*)value_;
- (void)addBlueAllianceObject:(Team*)value_;
- (void)removeBlueAllianceObject:(Team*)value_;

- (void)addMedia:(NSSet*)value_;
- (void)removeMedia:(NSSet*)value_;
- (void)addMediaObject:(Media*)value_;
- (void)removeMediaObject:(Media*)value_;

- (void)addRedAlliance:(NSOrderedSet*)value_;
- (void)removeRedAlliance:(NSOrderedSet*)value_;
- (void)addRedAllianceObject:(Team*)value_;
- (void)removeRedAllianceObject:(Team*)value_;

@end

@interface _Match (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBlueScore;
- (void)setPrimitiveBlueScore:(NSNumber*)value;

- (int32_t)primitiveBlueScoreValue;
- (void)setPrimitiveBlueScoreValue:(int32_t)value_;




- (NSString*)primitiveComp_level;
- (void)setPrimitiveComp_level:(NSString*)value;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSNumber*)primitiveMatch_number;
- (void)setPrimitiveMatch_number:(NSNumber*)value;

- (int32_t)primitiveMatch_numberValue;
- (void)setPrimitiveMatch_numberValue:(int32_t)value_;




- (NSNumber*)primitiveRedScore;
- (void)setPrimitiveRedScore:(NSNumber*)value;

- (int32_t)primitiveRedScoreValue;
- (void)setPrimitiveRedScoreValue:(int32_t)value_;




- (NSNumber*)primitiveSet_number;
- (void)setPrimitiveSet_number:(NSNumber*)value;

- (int32_t)primitiveSet_numberValue;
- (void)setPrimitiveSet_numberValue:(int32_t)value_;




- (NSString*)primitiveTime_string;
- (void)setPrimitiveTime_string:(NSString*)value;





- (NSMutableOrderedSet*)primitiveBlueAlliance;
- (void)setPrimitiveBlueAlliance:(NSMutableOrderedSet*)value;



- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;



- (NSMutableSet*)primitiveMedia;
- (void)setPrimitiveMedia:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitiveRedAlliance;
- (void)setPrimitiveRedAlliance:(NSMutableOrderedSet*)value;


@end
