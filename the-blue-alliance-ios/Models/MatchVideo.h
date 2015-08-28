#import "_MatchVideo.h"

typedef NS_ENUM(NSInteger, MatchVideoType) {
    MatchVideoTypeYouTube,
    MatchVideoTypeTBA
};

@interface MatchVideo : _MatchVideo {}

+ (instancetype)insertMatchVideoWithModelMatchVideo:(TBAMatchVideo *)modelMatchVideo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertMatchVidoesWithModelMatchVidoes:(NSArray *)modelMatchVidoes inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSURL *)videoUrl;

@end
