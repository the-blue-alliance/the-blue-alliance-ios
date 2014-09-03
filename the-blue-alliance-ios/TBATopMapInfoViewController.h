//
//  TBATopMapInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TBAInfoTableViewDataRow.h"


@interface TBATopMapInfoViewController : UIViewController


@property (nonatomic) MKCoordinateRegion mapRegion;

// Override:
- (NSString *)mapTitle;
- (NSArray *)loadInfoObjects;

@end
