//
//  GradientView.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 30/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    
    NSArray * colors = @[(__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor,
                         (__bridge id)[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0].CGColor];
    
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGPoint startPoint  = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint endPoint    = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, self.bounds);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpace);
}


@end
