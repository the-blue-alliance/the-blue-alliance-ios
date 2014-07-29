//
//  EventsMapView.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/27/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "EventsMapView.h"
#import "Event.h"
#import <JMMarkSlider.h>

@interface EventsMapView () <UIToolbarDelegate>
@property (nonatomic, strong) JMMarkSlider *slider;
@property (nonatomic) int lastSliderIndex;
@end

@implementation EventsMapView


- (NSInteger)getSliderIndexForDate:(NSDate *)date
{
    if (!date) {
        return -1;
    }
    return ([self.seasonStartDate distanceInDaysToDate:date] / 7) + 1;
}

- (void)setSeasonStartDate:(NSDate *)seasonStartDate
{
    _seasonStartDate = seasonStartDate;
    
    int week = [self getSliderIndexForDate:[NSDate date]] - 1;
    [self setSliderIndex:week snapTo:YES];
}


- (void)setSortedIndexTitles:(NSArray *)sortedIndexTitles
{
    _sortedIndexTitles = sortedIndexTitles;
    
    self.slider.annotations = sortedIndexTitles;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        NSLog(@"setup");
        
        UIView *topToolbar = [[UIView alloc] initForAutoLayout];
        [self addSubview:topToolbar];
        [topToolbar autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [topToolbar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [topToolbar autoSetDimension:ALDimensionHeight toSize:60];
        [topToolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [topToolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        topToolbar.backgroundColor = [UIColor TBANavigationBarColor];
        
        self.lastSliderIndex = -1;
        self.slider = [[JMMarkSlider alloc] initForAutoLayout];
        self.slider.contentMode = UIViewContentModeRedraw;
        self.slider.minimumValue = 0;
        self.slider.maximumValue = 1;
        [topToolbar addSubview:self.slider];
        [self.slider autoAlignAxis:ALAxisHorizontal toSameAxisOfView:topToolbar withOffset:10];
        [self.slider autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
        [self.slider autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];
        
        [self.slider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSliderIndex:(int)index snapTo:(BOOL)snap
{
    index = MIN(index, self.slider.annotations.count - 1);
    self.slider.boldAnnotationIndex = index;
    
    if(snap) {
        float val = self.slider.minimumValue + ([self.slider.markPositions[index] floatValue] / 100 * (self.slider.maximumValue - self.slider.minimumValue));
        float distFromMiddle = ABS(val - (self.slider.maximumValue - self.slider.minimumValue)/2);
        float sign = val > (self.slider.maximumValue - self.slider.minimumValue)/2 ? 1 : -1;
        float SPREAD_K = 35.5 / self.slider.frame.size.width;
        
        self.slider.value = val + SPREAD_K*sign*distFromMiddle;
    }

    if(index != self.lastSliderIndex) {
        [self removeAnnotations:self.annotations];
        NSArray *events = self.eventData[self.sortedIndexTitles[index]];
        for (Event *event in events) {
            if(ABS(event.cachedLocationLatValue) > FLT_EPSILON && ABS(event.cachedLocationLonValue) > FLT_EPSILON) {
                [self addAnnotation:event];
            }
        }
        self.lastSliderIndex = index;
    }
}

- (void)sliderUpdate:(JMMarkSlider *)slider
{
    float minDistance = FLT_MAX;
    NSInteger minIndex = -1;
    float value = slider.value;
    int index = 0;
    for (NSNumber *num in slider.markPositions) {
        float markVal = (slider.maximumValue - slider.minimumValue) * num.floatValue / 100;
        float dist = ABS(markVal - value);
        if (dist < minDistance) {
            minDistance = dist;
            minIndex = index;
        }
        index++;
    }
    [self setSliderIndex:minIndex snapTo:NO];
}

- (void)sliderDone:(JMMarkSlider *)slider
{
    float minDistance = FLT_MAX;
    NSInteger minIndex = -1;
    float minMarkVal = 0;
    float value = slider.value;
    int index = 0;
    for (NSNumber *num in slider.markPositions) {
        float markVal = (slider.maximumValue - slider.minimumValue) * num.floatValue / 100;
        float dist = ABS(markVal - value);
        if (dist < minDistance) {
            minDistance = dist;
            minIndex = index;
            minMarkVal = markVal;
        }
        index++;
    }

    
    [self setSliderIndex:minIndex snapTo:YES];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *note = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Event Annotation"];
    if(!note) {
        note = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Event Annotation"];
        note.enabled = YES;
        note.canShowCallout = YES;
    }
    note.annotation = annotation;
    
    return note;
}


@end
