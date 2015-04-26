//
//  District.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "District.h"

@implementation District

+ (NSArray *)districtTypes {
    return @[@(TBADistrictTypeMichigan), @(TBADistrictTypeMidAtlantic), @(TBADistrictTypeNewEngland), @(TBADistrictTypePacificNorthwest), @(TBADistrictTypeIndiana)];
}

+ (NSString *)nameForDistrictType:(TBADistrictType)type {
    switch (type) {
        case TBADistrictTypeNoDistrict:
            return nil;
        case TBADistrictTypeMichigan:
            return @"Michigan";
        case TBADistrictTypeMidAtlantic:
            return @"Mid Atlantic";
        case TBADistrictTypeNewEngland:
            return @"New England";
        case TBADistrictTypePacificNorthwest:
            return @"Pacific Northwest";
        case TBADistrictTypeIndiana:
            return @"Indiana";
    }
}

+ (NSString *)abbrevForDistrictType:(TBADistrictType)type {
    switch (type) {
        case TBADistrictTypeNoDistrict:
            return nil;
        case TBADistrictTypeMichigan:
            return @"fim";
        case TBADistrictTypeMidAtlantic:
            return @"mar";
        case TBADistrictTypeNewEngland:
            return @"ne";
        case TBADistrictTypePacificNorthwest:
            return @"pnw";
        case TBADistrictTypeIndiana:
            return @"in";
    }
}

@end
