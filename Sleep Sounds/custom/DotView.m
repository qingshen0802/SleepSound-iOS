//
//  DotView.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "DotView.h"

@implementation DotView

- (void)setPercent:(double)p
{
    _percent = p;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect rectangle = self.bounds;
    
    CGFloat dashPattern[]= {1, 1};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineDash(context, 0.0, dashPattern, 2);
    CGContextMoveToPoint(context, 0, rectangle.size.height/2);
    CGContextAddLineToPoint(context, rectangle.size.width*_percent, rectangle.size.height/2);
    CGContextStrokePath(context);
}

@end
