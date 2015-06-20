// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventAlliance.h instead.

#import <CoreData/CoreData.h>

extern const struct EventAllianceAttributes {
	__unsafe_unretained NSString *declines;
	__unsafe_unretained NSString *picks;
} EventAllianceAttributes;

extern const struct EventAllianceRelationships {
	__unsafe_unretained NSString *event;
} EventAllianceRelationships;

@class Event;

@class NSObject;

@class NSObject;

@interface EventAllianceID : NSManagedObjectID {}
@end

@interface _EventAlliance : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventAllianceID* objectID;

@property (nonatomic, strong) id declines;

//- (BOOL)validateDeclines:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id picks;

//- (BOOL)validatePicks:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@end

@interface _EventAlliance (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveDeclines;
- (void)setPrimitiveDeclines:(id)value;

- (id)primitivePicks;
- (void)setPrimitivePicks:(id)value;

- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;

@end
