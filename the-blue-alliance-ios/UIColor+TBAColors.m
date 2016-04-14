//
//  UIColor+TBAColors.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "UIColor+TBAColors.h"

@implementation UIColor (TBAColors)

+ (UIColor *)primaryBlue {
    return [UIColor colorWithRed:(63.0f/255.0f) green:(81.0f/255.0f) blue:(181.0f/255.0f) alpha:1.0f];
}

+ (UIColor *)primaryDarkBlue {
    return [UIColor colorWithRed:(48.0f/255.0f) green:(63.0f/255.0f) blue:(159.0f/255.0f) alpha:1.0f];
}

+ (UIColor *)lightRed {
    return [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:(34.0f/255.0f)];
}

+ (UIColor *)lighterRed {
    return [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:(17.0f/255.0f)];
}

+ (UIColor *)lightBlue {
    return [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:(34.0f/255.0f)];
}

+ (UIColor *)lighterBlue {
    return [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:(17.0f/255.0f)];
}

+ (UIColor *)blue {
    return [UIColor blueColor];
}

+ (UIColor *)red {
    return [UIColor redColor];
}

@end
