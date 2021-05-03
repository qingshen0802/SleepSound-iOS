//
//  MSoundManager.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MSoundManager.h"
#import "Utils.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SOUND_LIST_FILE         @"Sounds.plist"

@interface MSoundManager ()
@property (strong, nonatomic) NSMutableArray * sounds;
@end

@implementation MSoundManager

+ (MSoundManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MSoundManager * soundManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        soundManagerSharedInstance = [[MSoundManager alloc] init];
    });
    return soundManagerSharedInstance;
}

+ (void)activeAudioSession:(BOOL)active
{
    static int callCnt = 0;
    
    if( active )
    {
        if( callCnt == 0 )
        {
            NSLog(@"Audio Session: Active");
            
            NSError * setCategoryError = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
            if( setCategoryError != nil )
                NSLog(@"Audio Session set Category Error: %@", setCategoryError);
            else
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        
        callCnt++;
    }
    else
    {
        if( callCnt > 0 )
        {
            callCnt--;
            
            if( callCnt == 0 )
            {
                NSLog(@"Audio Session: Deactive");
                
                [[AVAudioSession sharedInstance] setActive:NO error:nil];
            }
        }
    }
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        
    }
    
    return self;
}

#pragma mark - Load
- (void)loadSounds
{
    NSString * listFile = [MSoundManager pathOfSoundXML];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:listFile] )
        [self installDefaults];
    else
    {
        NSArray * soundDics = [NSArray arrayWithContentsOfFile:listFile];
        self.sounds = [NSMutableArray array];
        for( NSDictionary * d in soundDics )
        {
            MSound * s = [[MSound alloc] initWithDictionary:d];
            [_sounds addObject:s];
        }
    }
}

- (void)installDefaults
{
    NSString * listFile = [MSoundManager pathOfSoundXML];
    
    //List File
    NSString * listFileInBundle = [[NSBundle mainBundle] pathForResource:SOUND_LIST_FILE ofType:nil];
    [[NSFileManager defaultManager] copyItemAtPath:listFileInBundle toPath:listFile error:nil];

    //Sound & Image
    NSArray * soundDics = [NSArray arrayWithContentsOfFile:listFile];
    self.sounds = [NSMutableArray array];
    for( NSDictionary * d in soundDics )
    {
        MSound * s = [[MSound alloc] initWithDictionary:d];
        [_sounds addObject:s];
        
        NSString * sPathInBundle = [[NSBundle mainBundle] pathForResource:s.sound ofType:nil];
        NSString * sPath = [[MSoundManager pathOfResources] stringByAppendingPathComponent:s.sound];
        [[NSFileManager defaultManager] copyItemAtPath:sPathInBundle toPath:sPath error:nil];
        
        NSString * bPathInBundle = [[NSBundle mainBundle] pathForResource:s.background ofType:nil];
        NSString * bPath = [[MSoundManager pathOfResources] stringByAppendingPathComponent:s.background];
        [[NSFileManager defaultManager] copyItemAtPath:bPathInBundle toPath:bPath error:nil];
    }
}

- (void)saveSounds
{
    NSMutableArray * array = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        NSDictionary * d = [s dictionary];
        [array addObject:d];
    }
    
    NSString * listFile = [MSoundManager pathOfSoundXML];
    [array writeToFile:listFile atomically:YES];
}

- (void)restoreSounds
{
    [_sounds enumerateObjectsUsingBlock:^(MSound * sound, NSUInteger idx, BOOL * _Nonnull stop) {
        if( sound.type == SOUND_MONEY ||
            sound.type == SOUND_VIDEO ||
            sound.type == SOUND_RATE )
            sound.isUsable = NO;
    }];
}

- (NSArray *)purchasedSounds
{
    NSMutableArray * PSounds = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        if( s.isUsable )
            [PSounds addObject:s];
    }
    
    return PSounds;
}

- (NSArray *)notPurchasedSounds
{
    NSMutableArray * PSounds = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        if( !s.isUsable && s.type == SOUND_MONEY )
            [PSounds addObject:s];
    }
    
    return PSounds;
}

- (NSArray *)videoPurchaseSounds
{
    NSMutableArray * PSounds = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        if( !s.isUsable && s.type == SOUND_VIDEO )
            [PSounds addObject:s];
    }
    
    return PSounds;
}

- (NSArray *)playingSounds
{
    NSMutableArray * PSounds = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        if( s.isPlaying )
            [PSounds addObject:s];
    }
    
    return PSounds;
}

- (NSArray *)soundForRate
{
    NSMutableArray * PSounds = [NSMutableArray array];
    for( MSound * s in _sounds )
    {
        if( s.type == SOUND_RATE )
            [PSounds addObject:s];
    }
    
    return PSounds;
}

- (MSound *)soundForId:(NSString *)Id
{
    for( MSound * s in _sounds )
    {
        if( [s.uniqueId isEqualToString:Id] )
            return s;
    }
    
    return nil;
}

#pragma mark - Path
+ (NSString *)pathOfResources
{
    NSString * path = [[Utils pathOfDocument] stringByAppendingPathComponent:@"Sounds"];
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path] )
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}

+ (NSString *)pathOfSoundXML
{
    NSString * listFile = [[MSoundManager pathOfResources] stringByAppendingPathComponent:SOUND_LIST_FILE];
    return listFile;
}

@end
