//
//  AnnotatedJMMarkSlider.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 8/3/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "AnnotatedJMMarkSlider.h"

@implementation AnnotatedJMMarkSlider


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.boldAnnotationIndex = -1;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.boldAnnotationIndex = -1;
    }
    return self;
}

- (UIFont *)annotationFont
{
    return [UIFont systemFontOfSize:10];
}

- (UIFont *)boldAnnotationFont
{
    return [UIFont boldSystemFontOfSize:11];
}

- (void)setBoldAnnotationIndex:(NSInteger)index
{
    _boldAnnotationIndex = index;
    [self setNeedsLayout];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    
    float gapSize = 100 / (annotations.count + 1);
    float position = gapSize;
    NSMutableArray *markerPositions = [[NSMutableArray alloc] initWithCapacity:annotations.count];
    for (NSString *note in annotations) {
        [markerPositions addObject:@(position)];
        position += gapSize;
    }
    self.markPositions = markerPositions;
    [self setNeedsLayout];
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    for(int i = 0; i < self.subviews.count; i++) {
        UIView *sub = self.subviews[i];
        if([sub isKindOfClass:[UILabel class]]) {
            [sub removeFromSuperview];
            i--;
        }
    }
    
    
    CGRect innerRect = CGRectInset(self.bounds, 1.0, 10.0);
    float gapSize = 100 / (self.annotations.count + 1);
    float position = gapSize;
    NSInteger index = 0;
    for (NSString *note in self.annotations) {
        
        float labelPos = position * innerRect.size.width / 100.0f;
        
        UIFont *font = nil;
        if(index == self.boldAnnotationIndex) {
            font = [self boldAnnotationFont];
        } else {
            font = [self annotationFont];
        }
        
        UIColor *color = [UIColor whiteColor];
        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: color};
        NSAttributedString *attributedNote = [[NSAttributedString alloc] initWithString:note attributes:attributes];
        CGSize fitSize = [attributedNote size];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fitSize.width, fitSize.height)];
        label.attributedText = attributedNote;
        label.center = CGPointMake(labelPos, -fitSize.height/2);
        [self addSubview:label];
        
        
        position += gapSize;
        index++;
    }
}


@end
