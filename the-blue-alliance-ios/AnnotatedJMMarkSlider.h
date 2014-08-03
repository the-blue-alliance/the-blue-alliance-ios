//
//  AnnotatedJMMarkSlider.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 8/3/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "JMMarkSlider.h"

@interface AnnotatedJMMarkSlider : JMMarkSlider

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic) NSInteger boldAnnotationIndex;

@end
