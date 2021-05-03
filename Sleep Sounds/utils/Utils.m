//
//  Utils.m
//  AirMito
//
//  Created by Ditriol Wei on 09/3/15.
//  Copyright (c) 2015 NewTech Software Inc. All rights reserved.
//

#import "Utils.h"
#import <sys/time.h>

@implementation Utils

+ (NSInteger)getSystemVersionAsInteger
{
    int index = 0;
    NSInteger version = 0;
    
    NSArray * digits = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSEnumerator * enumer = [digits objectEnumerator];
    NSString * number = nil;
    
    while( (number = [enumer nextObject]) )
    {
        if( index > 2 )
            break;
        
        NSInteger multipler = powf(100, 2-index);
        
        version += [number intValue] * multipler;
        
        index ++;
    }
    
    return version;
    
    /*
     
     You can use this version as follows.
     
     if( [Utils getSystemVersionAsInteger] >= __IPHONE_4_0 )
     {
     
     }
     else if( [[Utils getSystemVersionAsInteger] > 40300 ) //iOS 4.3
     {
     
     }
     
     */
}

+ (UIColor *)appBackgroundColor
{
    return [UIColor colorWithRed:0.9686 green:0.9686 blue:0.9686 alpha:1.0];
}

+ (UIColor *)appBlueColor
{
    return [UIColor colorWithRed:0.00784f green:0.694f blue:0.7058 alpha:1.0f];
}

+ (NSString *)stringForForDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d, yyyy"];
    NSString * stringDate = [formatter stringFromDate:date];
    return stringDate;
}

#pragma mark - Time
+ (double)getTime
{
    struct timeval time;
    gettimeofday(&time, NULL);
    double sec = time.tv_sec;
    double usc = time.tv_usec;
    double curTime = sec + usc / 1000000.0f;
    return curTime;
}

+ (NSString *)minute_sec:(NSInteger)sec
{
    NSInteger m = sec / 60;
    NSInteger s = sec % 60;
    return [NSString stringWithFormat:@"%02d:%02d", (int)m, (int)s];
}

#pragma mark - Path
+ (NSString *)pathOfDocument
{
    NSArray * searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if( searchPath == nil || [searchPath count] == 0 )
        return nil;
    NSString * documentDirectory = [searchPath objectAtIndex:0];
    return documentDirectory;
}

#pragma mark - Overlay
+ (UIImage *)image:(UIImage *)image coverOverlayWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Fonts
+(UIFont *)fontMyriadProLightWithSize:(CGFloat)size
{
    UIFont * font = [UIFont fontWithName:@"MyriadPro-Light" size:size];
    return font;
}

#pragma mark - Device
+ (BOOL)isIPAD
{
    return ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
}

+ (BOOL)isIPHONE
{
    return ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone );
}

#pragma mark - Height
+ (CGFloat)heightOfText:(NSString *)t forWidth:(CGFloat)w font:(UIFont *)f
{
    CGRect r = [t boundingRectWithSize:CGSizeMake(w, 0)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName:f}
                               context:nil];
    return r.size.height;
}

#pragma mark - Unique Id
+ (NSString *)uniqueId
{
    static long long numberForUniqueID = 0;
    
    if( numberForUniqueID == 0 )
        numberForUniqueID = (long long)[NSDate timeIntervalSinceReferenceDate] * 1000;
    else
        numberForUniqueID++;
    
    NSString * uId = [NSString stringWithFormat:@"%lld", numberForUniqueID];
    return uId;
}
@end
