//
//  TeamInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamInfoViewController.h"

@interface TeamInfoViewController ()

@end

@implementation TeamInfoViewController



- (NSString *)title {
    return @"Info";
}


#pragma mark - TBATopMapInfoViewController overrides
- (NSString *)mapTitle
{
    return [NSString stringWithFormat:@"%@\nfrom %@", self.team.nickname, self.team.location];
}

- (NSString *)locationString
{
    return self.team.location;
}

- (NSArray *)loadInfoObjects
{
    TBATopMapInfoViewControllerInfoRowObject *websiteInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    websiteInfo.text = self.team.website.length ? self.team.website : @"No website";
    websiteInfo.icon = [UIImage imageNamed:@"website"];
    
    TBATopMapInfoViewControllerInfoRowObject *rookieYearInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
#warning TODO: Implement rookie year
    rookieYearInfo.text = @"ROOKIE YEAR";
    rookieYearInfo.icon = [UIImage imageNamed:@"calendar"];
    
    TBATopMapInfoViewControllerInfoRowObject *locationInfo = [[TBATopMapInfoViewControllerInfoRowObject alloc] init];
    locationInfo.text = self.team.location;
    locationInfo.icon = [UIImage imageNamed:@"location"];
    
    return @[websiteInfo, rookieYearInfo, locationInfo];
}

@end
