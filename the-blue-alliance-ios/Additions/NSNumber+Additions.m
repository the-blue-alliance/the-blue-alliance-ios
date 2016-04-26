//
//  NSNumber+Additions.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/25/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "NSNumber+Additions.h"

@implementation NSNumber (Additions)

- (NSString *)stringWithSuffix {
    int ones = self.integerValue % 10;
    int tens = (self.integerValue / 10) % 10;
    
    NSString *suffix;
    if (tens == 1) {
        suffix = @"th";
    } else if (ones == 1){
        suffix = @"st";
    } else if (ones == 2){
        suffix = @"nd";
    } else if (ones == 3){
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    
    return [NSString stringWithFormat:@"%@%@", self.stringValue, suffix];
}


@end
