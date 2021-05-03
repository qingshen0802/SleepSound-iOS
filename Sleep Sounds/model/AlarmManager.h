//
//  AlarmManager.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 30/10/15.
//  Copyright © 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alarm.h"

@interface AlarmManager : NSObject

+ (AlarmManager *)sharedInstance;

- (NSArray *)availableAlarms;
- (void)addAlarm:(Alarm *)alarm;
- (void)removeAlarm:(Alarm *)alarm;
- (BOOL)removeAlarmWithUniqueId:(NSString *)uId;
- (void)saveAlarms;

- (Alarm *)activeAlarm;

- (void)exchangeAlarmIndex:(NSUInteger)idx1 withIndex:(NSUInteger)idx2;

@end
