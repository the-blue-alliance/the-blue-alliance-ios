#import "_District.h"

@interface District : _District {}

+ (NSArray *)districtTypes;

+ (instancetype)insertDistrictWithDistrictDict:(NSDictionary *)districtDict forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictsWithDistrictDicts:(NSArray *)districtDicts forYear:(NSInteger)year inManagedObjectContext:(NSManagedObjectContext *)context;

@end
