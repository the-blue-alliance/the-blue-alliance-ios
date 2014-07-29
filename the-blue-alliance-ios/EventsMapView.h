//
//  EventsMapView.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/27/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface EventsMapView : MKMapView <MKMapViewDelegate>
@property (nonatomic, strong) NSArray *sortedIndexTitles;
@property (nonatomic, strong) NSDictionary *eventData;
@property (nonatomic, strong) NSDate *seasonStartDate;

@property (nonatomic, weak) UIViewController *controllerToSegueFrom;
@end
