//
//  Utils.h
//  AirMito
//
//  Created by Ditriol Wei on 09/3/15.
//  Copyright (c) 2015 NewTech Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (NSInteger)getSystemVersionAsInteger;

+ (UIColor *)appBackgroundColor;
+ (UIColor *)appBlueColor;

+ (NSString *)stringForForDate:(NSDate *)date;

#pragma mark - Time
+ (double)getTime;
+ (NSString *)minute_sec:(NSInteger)sec;

#pragma mark - Path
+ (NSString *)pathOfDocument;

#pragma mark - Overlay
+ (UIImage *)image:(UIImage *)image coverOverlayWithColor:(UIColor *)color;

#pragma mark - Fonts
+(UIFont *)fontMyriadProLightWithSize:(CGFloat)size;

#pragma mark - Device
+ (BOOL)isIPAD;
+ (BOOL)isIPHONE;

#pragma mark - Height
+ (CGFloat)heightOfText:(NSString *)t forWidth:(CGFloat)w font:(UIFont *)f;

#pragma mark - Unique Id
+ (NSString *)uniqueId;

@end
