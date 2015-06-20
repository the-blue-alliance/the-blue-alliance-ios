// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventWebcast.h instead.

#import <CoreData/CoreData.h>

extern const struct EventWebcastAttributes {
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *webcastType;
} EventWebcastAttributes;

extern const struct EventWebcastRelationships {
	__unsafe_unretained NSString *event;
} EventWebcastRelationships;

@class Event;

@interface EventWebcastID : NSManagedObjectID {}
@end

@interface _EventWebcast : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventWebcastID* objectID;

@property (nonatomic, strong) NSString* channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* webcastType;

@property (atomic) int64_t webcastTypeValue;
- (int64_t)webcastTypeValue;
- (void)setWebcastTypeValue:(int64_t)value_;

//- (BOOL)validateWebcastType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@end

@interface _EventWebcast (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChannel;
- (void)setPrimitiveChannel:(NSString*)value;

- (NSString*)primitiveFile;
- (void)setPrimitiveFile:(NSString*)value;

- (NSNumber*)primitiveWebcastType;
- (void)setPrimitiveWebcastType:(NSNumber*)value;

- (int64_t)primitiveWebcastTypeValue;
- (void)setPrimitiveWebcastTypeValue:(int64_t)value_;

- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;

@end
