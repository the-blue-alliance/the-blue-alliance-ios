// Renders a single app icon appearance out of a compiled asset catalog.
//
// Icon Composer (.icon) files have no raster form that UIImage(named:) can load, and
// actool has no public flag to emit an appearance-specific standalone render. The
// composed renditions only exist inside the Assets.car that actool produces, so this
// reads them back out via CoreUI.
//
// Compiled on demand by generate-app-icon-previews.sh; never shipped in the app.
//
//   usage: AppIconPreviewExtractor <Assets.car> <IconName> <Appearance> <output.png>
//   where <Appearance> is UIAppearanceAny (light) or UIAppearanceDark

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <objc/message.h>

@interface CUICatalog : NSObject
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;
- (NSArray *)imagesWithName:(NSString *)name;
@end

int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc != 5) {
            fprintf(stderr, "usage: %s <Assets.car> <IconName> <Appearance> <output.png>\n", argv[0]);
            return 2;
        }
        NSString *carPath = @(argv[1]);
        NSString *iconName = @(argv[2]);
        NSString *wantAppearance = @(argv[3]);
        NSString *outPath = @(argv[4]);

        if (!dlopen("/System/Library/PrivateFrameworks/CoreUI.framework/CoreUI", RTLD_NOW)) {
            fprintf(stderr, "error: could not load CoreUI\n");
            return 1;
        }
        Class catalogClass = NSClassFromString(@"CUICatalog");
        if (!catalogClass) {
            fprintf(stderr, "error: CUICatalog unavailable\n");
            return 1;
        }

        NSError *error = nil;
        CUICatalog *catalog = [[catalogClass alloc] initWithURL:[NSURL fileURLWithPath:carPath]
                                                          error:&error];
        if (!catalog) {
            fprintf(stderr, "error: could not open %s\n", carPath.UTF8String);
            return 1;
        }

        NSArray *images = nil;
        @try {
            images = [catalog imagesWithName:iconName];
        } @catch (NSException *e) {
            fprintf(stderr, "error: no renditions for %s\n", iconName.UTF8String);
            return 1;
        }

        // Keep the largest rendition matching the requested appearance. The image is read
        // through objc_msgSend because KVC cannot box the returned CGImageRef.
        CGImageRef (*copyImage)(id, SEL) = (CGImageRef(*)(id, SEL))objc_msgSend;
        CGImageRef best = NULL;
        size_t bestWidth = 0;
        for (id image in images) {
            id appearance = nil;
            @try {
                appearance = [image valueForKey:@"appearance"];
            } @catch (NSException *e) {
                continue;
            }
            if (![wantAppearance isEqualToString:[appearance description]]) continue;

            CGImageRef candidate = NULL;
            @try {
                candidate = copyImage(image, NSSelectorFromString(@"image"));
            } @catch (NSException *e) {
                continue;
            }
            if (!candidate) continue;
            size_t width = CGImageGetWidth(candidate);
            if (width > bestWidth) {
                bestWidth = width;
                best = candidate;
            }
        }

        if (!best) {
            fprintf(stderr, "error: no %s rendition for %s\n", wantAppearance.UTF8String,
                    iconName.UTF8String);
            return 1;
        }

        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
            (__bridge CFURLRef)[NSURL fileURLWithPath:outPath], (__bridge CFStringRef) @"public.png",
            1, NULL);
        if (!destination) {
            fprintf(stderr, "error: could not write %s\n", outPath.UTF8String);
            return 1;
        }
        CGImageDestinationAddImage(destination, best, NULL);
        BOOL ok = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        if (!ok) {
            fprintf(stderr, "error: could not encode %s\n", outPath.UTF8String);
            return 1;
        }
        printf("%zu\n", bestWidth);
    }
    return 0;
}
