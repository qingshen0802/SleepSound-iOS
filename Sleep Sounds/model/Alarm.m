//
//  Alarm.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 28/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "Alarm.h"
#import "Favorite.h"
#import "Utils.h"

@implementation Alarm

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        self.type = 0;
        [self setup];
    }
    
    return self;
}

- (id)initAlarm
{
    self = [super init];
    if( self != nil )
    {
        self.type = 0;
        [self setup];
    }
    
    return self;
}

- (id)initTimer
{
    self = [super init];
    if( self != nil )
    {
        self.type = 1;
        [self setup];
        self.exitApp = NO;
    }
    
    return self;
}

- (void)setup
{
    self.uniqueId = [NSString stringWithFormat:@"alarm_%@", [Utils uniqueId]];
    self.enabled = NO;
    self.soundId = nil;
    self.fadeInSec = 30;
    self.snoozeEanbled = _type?NO:YES;
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents * comps = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    if( comps.hour > 12 )
    {
        self.ampm = 1;
        self.hour = comps.hour-12;
        self.mins = comps.minute;
    }
    else
    {
        self.hour = 0;
        self.hour = comps.hour;
        self.mins = comps.minute;
    }
    self.countdownSec = -1;
}

- (id)initWithDictionary:(NSDictionary *)d
{
    self = [super init];
    if( self != nil )
    {
        self.uniqueId = [d objectForKey:@"uniqueId"];
        self.type = [[d objectForKey:@"type"] integerValue];
        self.soundId = [d objectForKey:@"soundId"];
        self.fadeInSec  = [[d objectForKey:@"fadeInSec"] integerValue];
        self.snoozeEanbled = [[d objectForKey:@"snoozeEnabled"] boolValue];
        self.hour = [[d objectForKey:@"hour"] integerValue];
        self.mins = [[d objectForKey:@"mins"] integerValue];
        self.ampm = [[d objectForKey:@"ampm"] integerValue];
        self.countdownSec = [[d objectForKey:@"countdownSec"] integerValue];
        self.exitApp = [[d objectForKey:@"exitapp"] boolValue];
        self.enabled = [[d objectForKey:@"enabled"] boolValue];
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    [d setObject:_uniqueId forKey:@"uniqueId"];
    [d setObject:[NSNumber numberWithBool:_enabled] forKey:@"enabled"];
    [d setObject:[NSNumber numberWithInteger:_type] forKey:@"type"];
    if( _soundId != nil )
        [d setObject:_soundId forKey:@"soundId"];
    [d setObject:[NSNumber numberWithInteger:_fadeInSec] forKey:@"fadeInSec"];
    [d setObject:[NSNumber numberWithBool:_snoozeEanbled] forKey:@"snoozeEnabled"];
    [d setObject:[NSNumber numberWithInteger:_hour] forKey:@"hour"];
    [d setObject:[NSNumber numberWithInteger:_mins] forKey:@"mins"];
    [d setObject:[NSNumber numberWithInteger:_ampm] forKey:@"ampm"];
    [d setObject:[NSNumber numberWithInteger:_countdownSec] forKey:@"countdownSec"];
    [d setObject:[NSNumber numberWithBool:_exitApp] forKey:@"exitapp"];
    
    return d;
}

- (void)setEnabled:(BOOL)b
{
    _enabled = b;
    
    if( _enabled )
        [self calculateFireInterval];
    else
        _fireInterval = 0;
}

- (void)calculateFireInterval
{
    if( self.countdownSec >= 0 )
        _fireInterval = self.countdownSec;
    else
    {
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents * comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                               fromDate:[NSDate date]];
        NSInteger hour = self.ampm==0?(self.hour%12):(self.hour%12)+12;
        NSInteger minu = self.mins;
        NSTimeInterval additional = 0;
        if( hour*60+minu <= comps.hour*60+comps.minute )
            additional = 24 * 3600;
        comps.hour = hour;
        comps.minute = minu;
        NSDate * fireDate = [calendar dateFromComponents:comps];
        _fireInterval = [fireDate timeIntervalSinceDate:[NSDate date]] + additional;
    }
    
    NSLog(@"Fire Interval: %ld", (long)_fireInterval);
}

#pragma mark - Public
- (NSString *)name
{
    NSString * alarmName;
    if( self.soundId == nil )
        alarmName = @"Use current mix selection";
    else
    {
        NSArray * favorites = [Favorite availableFavorites];
        for( Favorite * f in favorites )
        {
            if( [f.uniqueId isEqualToString:self.soundId] )
            {
                alarmName = f.name;
                break;
            }
        }
    }
    
    return alarmName;
}

- (NSString *)stringForFadeInSec
{
    NSString * str;
    
    if( _fadeInSec < 1 )
        str = @"None";
    else if( _fadeInSec < 60 )
    {
        str = [NSString stringWithFormat:@"%d seconds", (int)_fadeInSec];
    }
    else if( _fadeInSec < 120 )
    {
        str = [NSString stringWithFormat:@"%d minute", (int)_fadeInSec/60];
    }
    else
    {
        str = [NSString stringWithFormat:@"%d minutes", (int)_fadeInSec/60];
    }
    
    return str;
}

- (NSString *)stringForTime
{
    NSString * str;
    if( _countdownSec < 0 )
        str = [NSString stringWithFormat:@"%02d:%02d%@", (int)_hour, (int)_mins, _ampm==0?@"am":@"pm"];
    else
    {
        NSInteger sec = _enabled?_fireInterval:_countdownSec;
        NSInteger h = sec/3600;
        NSInteger m = (sec%3600)/60;
        NSInteger s = (sec%60);
        
        str = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)h, (int)m, (int)s];
    }
    
    return str;
}

@end
