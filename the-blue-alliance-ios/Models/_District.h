// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to District.h instead.

#import <CoreData/CoreData.h>

extern const struct DistrictAttributes {
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *year;
} DistrictAttributes;

extern const struct DistrictRelationships {
	__unsafe_unretained NSString *districtRankings;
} DistrictRelationships;

@class DistrictRanking;

@interface DistrictID : NSManagedObjectID {}
@end

@interface _District : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DistrictID* objectID;

@property (nonatomic, strong) NSString* key;

//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* year;

@property (atomic) int64_t yearValue;
- (int64_t)yearValue;
- (void)setYearValue:(int64_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *districtRankings;

- (NSMutableSet*)districtRankingsSet;

@end

@interface _District (DistrictRankingsCoreDataGeneratedAccessors)
- (void)addDistrictRankings:(NSSet*)value_;
- (void)removeDistrictRankings:(NSSet*)value_;
- (void)addDistrictRankingsObject:(DistrictRanking*)value_;
- (void)removeDistrictRankingsObject:(DistrictRanking*)value_;

@end

@interface _District (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int64_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int64_t)value_;

- (NSMutableSet*)primitiveDistrictRankings;
- (void)setPrimitiveDistrictRankings:(NSMutableSet*)value;

@end
