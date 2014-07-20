//
//  Media.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Media.h"


@implementation Media

- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context
                withUserInfo:(id)userInfo
{
    
    self.key = info[@"key"];
    self.type = info[@"type"];
    
    if([self.type isEqualToString:@"youtube"]) {
        self.url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.key];
    } else if([self.type isEqualToString:@"tba"]){
        self.url = info[@"key"];
    } else {
        [NSException raise:@"Unimplemented media type!" format:@"Media type %@ has not be implemented yet! (implement me pl0x)", self.type];
    }
}

@end
