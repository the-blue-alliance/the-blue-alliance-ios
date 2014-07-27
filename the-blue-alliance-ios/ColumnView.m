//
//  ColumnView.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "ColumnView.h"

@implementation ColumnView



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString *approximatingHeader = [self.topRow componentsJoinedByString:@" "];
    CGFloat maxWidth = MIN(self.bounds.size.width, 198);
    int fontSize = 18;
    while([approximatingHeader sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:--fontSize]}].width > maxWidth);
    NSDictionary *finalAttribs = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    
    CGFloat totalHorizontalTextWidth = 0;
    NSMutableArray *textSizeValues = [[NSMutableArray alloc] initWithCapacity:self.topRow.count];
    for (NSString *header in self.topRow) {
        CGSize size = [header sizeWithAttributes:finalAttribs];
        totalHorizontalTextWidth += size.width;
        [textSizeValues addObject:[NSValue valueWithCGSize:size]];
    }
    
    NSInteger numSpacers = self.topRow.count + 1;
    int spacerWidth = (self.bounds.size.width - totalHorizontalTextWidth)/numSpacers; // Convert to int to avoid non-integer rects
    spacerWidth = MIN(spacerWidth, 40);
    
    CGFloat currentX = spacerWidth;
    for (int i = 0; i < self.topRow.count; i++) {
        NSString *header = self.topRow[i];
        NSString *value = self.bottomRow[i];
        
        CGSize size = [textSizeValues[i] CGSizeValue];
        CGSize valueSize = [value sizeWithAttributes:finalAttribs];
        
        [header drawAtPoint:CGPointMake(currentX, 0) withAttributes:finalAttribs];
        [value drawAtPoint:CGPointMake(currentX - (valueSize.width - size.width)/2, self.bounds.size.height - valueSize.height) withAttributes:finalAttribs];
        
        currentX += size.width + spacerWidth;
    }
    
    
}


@end
