//
//  Alarm.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 28/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ALARM   0
#define TIMER   1

@interface Alarm : NSObject

@property (strong, nonatomic) NSString * uniqueId;
@property (assign, nonatomic) BOOL enabled;

/*
    0: Alarm
    1: Timer
 */
@property (assign, nonatomic) NSInteger type;

/* 
    Favorite sound group's unique id
    nil means "Use current mix selection"
 */
@property (strong, nonatomic) NSString * soundId;

/*
    Fade In(Alarm) and Fade Out(Timer) seconds
 */
@property (assign, nonatomic) NSInteger fadeInSec;
@property (assign, nonatomic) BOOL      snoozeEanbled;
@property (assign, nonatomic) NSInteger countdownSec; // -1 means "has not been set"
@property (assign, nonatomic) NSInteger hour; //[1, 12]
@property (assign, nonatomic) NSInteger mins; //[0, 59]
@property (assign, nonatomic) NSInteger ampm; //0: AM, 1: PM

/*
    Indicate whether app should be exited when Timer fires out.
 */
@property (assign, nonatomic) BOOL exitApp;

- (id)initAlarm;
- (id)initTimer;
- (id)initWithDictionary:(NSDictionary *)d;
- (NSDictionary *)dictionary;

- (NSString *)name;
- (NSString *)stringForFadeInSec;
- (NSString *)stringForTime;

/*  The remain seconds until timer will be fired. */
@property (assign, nonatomic) NSTimeInterval fireInterval;
- (void)calculateFireInterval;

@end
