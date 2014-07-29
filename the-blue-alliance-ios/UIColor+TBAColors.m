//
//  UIColor+TBAColors.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "UIColor+TBAColors.h"

@implementation UIColor (TBAColors)

+ (UIColor *)TBANavigationBarColor
{
    return [UIColor colorWithRed:0.2
                           green:0.2
                            blue:0.85
                           alpha:1.0];
}

+ (UIColor *)TBATableViewSeparatorColor
{
//    return [UIColor colorWithRed:FBTweakValue(@"Table Separators", @"Color", @"Red", 0.146, 0.0, 1.0) green:FBTweakValue(@"Table Separators", @"Color", @"Green", 0.370, 0.0, 1.0) blue:FBTweakValue(@"Table Separators", @"Color", @"Blue", 0.741, 0.0, 1.0) alpha:1.0];
    
    return [UIColor TBATintColor];
}

+ (UIColor *)TBATintColor
{
//    return [UIColor colorWithRed:0.146 green:0.370 blue:0.741 alpha:1.000];
    
    // New, lighter color
    return [UIColor colorWithRed:0.75
                           green:0.85
                            blue:1.0
                           alpha:1.0];
}
@end
