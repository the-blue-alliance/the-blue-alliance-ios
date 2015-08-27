// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventRanking.h instead.

#import <CoreData/CoreData.h>

extern const struct EventRankingAttributes {
	__unsafe_unretained NSString *info;
	__unsafe_unretained NSString *rank;
	__unsafe_unretained NSString *record;
} EventRankingAttributes;

extern const struct EventRankingRelationships {
	__unsafe_unretained NSString *event;
	__unsafe_unretained NSString *team;
} EventRankingRelationships;

@class Event;
@class Team;

@class NSObject;

@interface EventRankingID : NSManagedObjectID {}
@end

@interface _EventRanking : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventRankingID* objectID;

@property (nonatomic, strong) id info;

//- (BOOL)validateInfo:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rank;

@property (atomic) int64_t rankValue;
- (int64_t)rankValue;
- (void)setRankValue:(int64_t)value_;

//- (BOOL)validateRank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* record;

//- (BOOL)validateRecord:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Team *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;

@end

@interface _EventRanking (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveInfo;
- (void)setPrimitiveInfo:(id)value;

- (NSNumber*)primitiveRank;
- (void)setPrimitiveRank:(NSNumber*)value;

- (int64_t)primitiveRankValue;
- (void)setPrimitiveRankValue:(int64_t)value_;

- (NSString*)primitiveRecord;
- (void)setPrimitiveRecord:(NSString*)value;

- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;

- (Team*)primitiveTeam;
- (void)setPrimitiveTeam:(Team*)value;

@end
