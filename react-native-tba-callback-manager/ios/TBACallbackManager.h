#import <React/RCTBridgeModule.h>

@protocol TBACallbackManagerDelegate
- (void)moduleUnsupported;
@end

@interface TBACallbackManager : NSObject <RCTBridgeModule>

@property (nonatomic, weak, nullable) id<TBACallbackManagerDelegate> delegate;

@end
