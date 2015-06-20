#import "_DistrictRanking.h"

@interface DistrictRanking : _DistrictRanking {}

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;

@end
