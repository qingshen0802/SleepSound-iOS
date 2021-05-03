//
//  AlarmManager.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 30/10/15.
//  Copyright © 2015 Zen Labs LLC. All rights reserved.
//

#import "AlarmManager.h"
#import "Utils.h"
#import "AppDefine.h"
#import "BackgroundTaskManager.h"

#define ALARM_FILE       @"alarm.plist"

@interface AlarmManager ()
@property (strong, nonatomic) NSMutableArray * alarms;
@end

@implementation AlarmManager{
    BOOL isCancelThread;
    double preTime;
    NSTimer * backgroundTimer;
}

+ (AlarmManager *)sharedInstance
{
    static AlarmManager * singletonAlarmManager = nil;
    if( singletonAlarmManager == nil )
        singletonAlarmManager = [[AlarmManager alloc] init];
    return singletonAlarmManager;
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        self.alarms = [NSMutableArray array];
        
        /* Load Alarms */
        [self loadAlarms];
        
        /* Create Thread */
        isCancelThread = YES;
        [self doRunThread];
        
        /* Background Related */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        backgroundTimer = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (NSString *)pathForAlarms
{
    return [[Utils pathOfDocument] stringByAppendingPathComponent:ALARM_FILE];
}

- (void)loadAlarms
{
    [self.alarms removeAllObjects];
    NSString * path = [self pathForAlarms];
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
    {
        NSMutableArray * aa = [NSMutableArray arrayWithContentsOfFile:path];
        for( NSDictionary * a in aa )
        {
            Alarm * alarm = [[Alarm alloc] initWithDictionary:a];
            [self.alarms addObject:alarm];
        }
    }
}

- (void)saveAlarms
{
    NSMutableArray * aa = [NSMutableArray array];
    for( Alarm * a in _alarms )
        [aa addObject:[a dictionary]];
    
    [aa writeToFile:[self pathForAlarms] atomically:YES];
}

- (NSArray *)availableAlarms
{
    return _alarms;
}

- (void)addAlarm:(Alarm *)alarm
{
    [self.alarms addObject:alarm];
}

- (void)removeAlarm:(Alarm *)alarm
{
    [self removeAlarmWithUniqueId:alarm.uniqueId];
}

- (BOOL)removeAlarmWithUniqueId:(NSString *)uId
{
    BOOL isFound = NO;
    for( NSUInteger i = 0 ; i <  [self.alarms count] ; i++ )
    {
        Alarm * a = [self.alarms objectAtIndex:i];
        if( [uId isEqualToString:a.uniqueId] )
        {
            [self.alarms removeObjectAtIndex:i];
            isFound = YES;
            break;
        }
    }
    
    if( isFound )
        [self saveAlarms];
    
    return isFound;
}

- (Alarm *)activeAlarm
{
    Alarm * myAlarm = nil;
    int index = -1;
    for( int i = 0 ; i < [_alarms count] ; i++ )
    {
        Alarm * aAlarm = [_alarms objectAtIndex:i];
        if( aAlarm.enabled )
        {
            myAlarm = aAlarm;
            index = i;
            break;
        }
    }

    if( myAlarm != nil )
    {
        for( int i = index+1 ; i < [_alarms count] ; i++ )
        {
            Alarm * aAlarm = [_alarms objectAtIndex:i];
            if( myAlarm.fireInterval > aAlarm.fireInterval )
                myAlarm = aAlarm;
        }
    }
    
    return myAlarm;
}

- (void)exchangeAlarmIndex:(NSUInteger)idx1 withIndex:(NSUInteger)idx2
{
    [self.alarms exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self saveAlarms];
}

#pragma mark - Working Thread
- (void)doRunThread
{
    if( !isCancelThread )
    {
        preTime = [Utils getTime];
    }
    else
    {
        isCancelThread = NO;
        preTime = [Utils getTime];
        
        [NSThread detachNewThreadSelector:@selector(onWorkThread:) toTarget:self withObject:nil];
    }
}

- (void)doCancelThread
{
    isCancelThread = YES;
}

- (void)onWorkThread:(id)arg
{
    while( !isCancelThread )
    {
        double curTime = [Utils getTime];
        double dt = curTime - preTime;
        
        for( Alarm * alarm in self.alarms )
        {
            if( !alarm.enabled )
                continue;
            
            alarm.fireInterval -= dt;
            
            if( alarm.fireInterval <= 0 )
            {
                NSLog(@"Fire Alarm");
                
                if( alarm.snoozeEanbled )
                    [alarm calculateFireInterval];
                else
                    alarm.enabled = NO;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSDictionary * d = @{@"alarm":alarm};
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAlarmFireNotification object:nil userInfo:d];
                });
                
                [self saveAlarms];
            }
            else
            {
                if( alarm.countdownSec > 0 )
                {
                    //Countdown
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAlarmCountDownNotification object:alarm userInfo:nil];
                    });
                }
            }
        }
        
        [NSThread sleepForTimeInterval:0.5];
        
        preTime = curTime;
        
        /**** Find the first Alarm ***/
        Alarm * myAlarm = [self activeAlarm];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSDictionary * d = nil;
            if( myAlarm != nil )
                d = @{@"alarm":myAlarm};
            [[NSNotificationCenter defaultCenter] postNotificationName:kAlarmActiveNotification object:nil userInfo:d];
        });
    }
}

#pragma mark - Background Related
- (void)appDidEnterBackground:(NSNotification *)n
{
    //Check if there is an enabled alarm
    BOOL is = NO;
    for( Alarm * alarm in self.alarms )
    {
        if( alarm.type == 0 && alarm.enabled == YES )
        {
            is = YES;
            break;
        }
    }
    
    if( is )
    {
        [self createNewBackgroundTask:nil];
        backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(createNewBackgroundTask:) userInfo:nil repeats:YES];
    }
}

- (void)appDidBecomeActive:(NSNotification *)n
{
    if( backgroundTimer != nil )
    {
        [backgroundTimer invalidate];
        backgroundTimer = nil;
        
        [[BackgroundTaskManager sharedBackgroundTaskManager] endAllBackgroundTasks];
    }
}

- (void)createNewBackgroundTask:(NSTimer *)t
{
    [[BackgroundTaskManager sharedBackgroundTaskManager] beginNewBackgroundTask];
}

@end
