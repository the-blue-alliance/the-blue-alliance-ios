// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Media.h instead.

#import <CoreData/CoreData.h>


extern const struct MediaAttributes {
	__unsafe_unretained NSString *cachedData;
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *url;
} MediaAttributes;

extern const struct MediaRelationships {
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *matches;
	__unsafe_unretained NSString *teams;
} MediaRelationships;

extern const struct MediaFetchedProperties {
} MediaFetchedProperties;

@class Event;
@class Match;
@class Team;








@interface MediaID : NSManagedObjectID {}
@end

@interface _Media : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MediaID*)objectID;





@property (nonatomic, strong) NSData* cachedData;



//- (BOOL)validateCachedData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* channel;



//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;




@property (nonatomic, strong) NSSet *matches;

- (NSMutableSet*)matchesSet;




@property (nonatomic, strong) NSSet *teams;

- (NSMutableSet*)teamsSet;





@end

@interface _Media (CoreDataGeneratedAccessors)

- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

- (void)addMatches:(NSSet*)value_;
- (void)removeMatches:(NSSet*)value_;
- (void)addMatchesObject:(Match*)value_;
- (void)removeMatchesObject:(Match*)value_;

- (void)addTeams:(NSSet*)value_;
- (void)removeTeams:(NSSet*)value_;
- (void)addTeamsObject:(Team*)value_;
- (void)removeTeamsObject:(Team*)value_;

@end

@interface _Media (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveCachedData;
- (void)setPrimitiveCachedData:(NSData*)value;




- (NSString*)primitiveChannel;
- (void)setPrimitiveChannel:(NSString*)value;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMatches;
- (void)setPrimitiveMatches:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTeams;
- (void)setPrimitiveTeams:(NSMutableSet*)value;


@end
