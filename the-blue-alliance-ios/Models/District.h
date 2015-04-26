//
//  District.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBADistrictType) {
    TBADistrictTypeNoDistrict = 0,
    TBADistrictTypeMichigan = 1,
    TBADistrictTypeMidAtlantic = 2,
    TBADistrictTypeNewEngland = 3,
    TBADistrictTypePacificNorthwest = 4,
    TBADistrictTypeIndiana = 5
};

@interface District : NSObject

+ (NSArray *)districtTypes;
+ (NSString *)nameForDistrictType:(TBADistrictType)type;
+ (NSString *)abbrevForDistrictType:(TBADistrictType)type;

@end
