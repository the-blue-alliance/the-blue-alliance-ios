#import "TBACallbackManager.h"


@implementation TBACallbackManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(moduleUnsupported)
{
    if (self.delegate) {
        [self.delegate moduleUnsupported];
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
