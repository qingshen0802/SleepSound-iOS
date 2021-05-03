//
//  SoundController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "SoundController.h"
#import "MSoundManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageCache.h"
#import "UIImage+WB.h"
#import "DotView.h"
#import "UnlockController.h"

@interface SoundController ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UIView *greenSashView;
@property (strong, nonatomic) IBOutlet UIView *volumeControllerView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet DotView *dotView;

@property (strong, nonatomic) AVAudioPlayer * audioPlayer;
@property (strong, nonatomic) NSTimer * timer;

@end

@implementation SoundController

- (id)initWithSound:(MSound *)s
{
    self = [super initWithNibName:@"SoundController" bundle:nil];
    if( self != nil )
    {
        self.sound = s;
        
        self.sounds = nil;
        self.soundIndex = 0;
    }
    
    return self;
}

- (id)initWithSounds:(NSArray *)ss
{
    self = [super initWithNibName:@"SoundController" bundle:nil];
    if( self != nil )
    {
        self.sound = nil;
        
        self.sounds = [NSMutableArray arrayWithArray:ss];
        self.soundIndex = 0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //Background
    [self loadBackgroundImage];
    
    //Title
    [_titleLabel setText:self.sound.name];
    [_titleButton setSelected:NO];

    if( !self.sound.isUsable )
    {
        if( self.sound.type == SOUND_VIDEO )
        {
            [_titleButton setImage:[UIImage imageNamed:@"ad_play"] forState:UIControlStateNormal];
            [_titleLabel setText:@"Watch video to unlock"];
        }
        else if( self.sound.type == SOUND_MONEY )
        {
            [_titleButton setImage:nil forState:UIControlStateNormal];
            [_titleButton setEnabled:YES]; ///
            
            CGRect r = _titleLabel.frame;
            r.origin.x -= 35;
            r.size.width += 35;
            _titleLabel.frame = r;
        }else if (self.sound.type == SOUND_RATE) { ///
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"RateSound"] isEqualToString:@"rated"]) {
                [_titleButton setImage:nil forState:UIControlStateNormal];
                [_titleLabel setText:@"Rate to unlock"];
            }
            
        }
    }
    
    _dotView.percent = self.sound.volume;
    
    //Controller View
    //[_volumeControllerView setHidden:YES];
    [_greenSashView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)loadBackgroundImage
{
    UIImage * backgroundImage = [[ImageCache sharedInstance] imageNamed:self.sound.background];
    if( !self.sound.isUsable )
        backgroundImage = [backgroundImage imageWithWhiteBlackColor];
    [_backgroundImageView setImage:backgroundImage];
}

- (void)showController:(BOOL)show
{
    if( show )
    {
        CGRect r = _greenSashView.frame;
        r.size.height = 0;
        _greenSashView.frame = r;
        _greenSashView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect bounds = [self.view bounds];
            CGRect r1 = _volumeControllerView.frame;
            r1.origin.x = bounds.size.width - r1.size.width;
            _volumeControllerView.frame = r1;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect r1 = self.view.bounds;
                CGRect r2 = _greenSashView.frame;
                r2.size.height = r1.size.height;
                _greenSashView.frame = r2;
            } completion:^(BOOL finished) {
                [_titleButton setSelected:YES];
            }];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1
                              delay:0
                            options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                         animations:^{[UIView setAnimationRepeatCount:3];_titleButton.alpha = 0;}
                         completion:^(BOOL finished) {
                             _titleButton.alpha = 1;
                             [UIView animateWithDuration:0.3 animations:^{
                                 CGRect bounds = [self.view bounds];
                                 CGRect r = _volumeControllerView.frame;
                                 r.origin.x = bounds.size.width;
                                 _volumeControllerView.frame = r;
                             } completion:^(BOOL finished) {
                                 [_greenSashView setHidden:YES];
                                 [_titleButton setSelected:NO];
                             }];
                         }];
    }
}

#pragma mark - Event
- (IBAction)play:(id)sender
{
    if( self.sound.isUsable )
    {
        if( !_titleButton.selected )
        {
            //Play
            [self showController:YES];
            [self startPlaying];
        }
        else
        {
            //Pause
            [self showController:NO];
            [self stopPlaying];
        }
    }
    else
    {
        if( self.sound.type == SOUND_VIDEO )
        {
            if( _delegate != nil )
                [_delegate SoundControllerPlayingVideoAd:self];
        } else if (self.sound.type == SOUND_RATE) { ///
            if( _delegate != nil )
                [_delegate SoundControllerRate:self];
        } else { ///
//            [[UnlockController sharedInstance] buyUnlock1Month];
            [_delegate SoundControllerUnlockAll:self];
        }
    }
}

- (IBAction)volumeUp:(id)sender
{
    self.sound.volume += 0.1;
    if( self.sound.volume > 1.0f )
        self.sound.volume = 1.0f;
    
    _audioPlayer.volume = self.sound.volume;
    _dotView.percent = self.sound.volume;
}

- (IBAction)volumeDown:(id)sender
{
    self.sound.volume -= 0.1;
    if( self.sound.volume < 0 )
        self.sound.volume = 0;
    
    _audioPlayer.volume = self.sound.volume;
    _dotView.percent = self.sound.volume;
}

#pragma mark - Private
- (void)startPlaying
{
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(SoundControllerDidStartPlaying:)] )
        [_delegate SoundControllerDidStartPlaying:self];

    self.sound.isPlaying = YES;
    
    if( _audioPlayer == nil )
    {
        NSString * path = [[MSoundManager pathOfResources] stringByAppendingPathComponent:self.sound.sound];
        if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
        {
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
            
            [_audioPlayer setVolume:self.sound.volume];
            [_audioPlayer setNumberOfLoops:-1];
            [_audioPlayer prepareToPlay];
        }
    }
    [_audioPlayer play];
}

- (void)stopPlaying
{
    [_audioPlayer stop];
    self.audioPlayer = nil;

    self.sound.isPlaying = NO;
    
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(SoundControllerDidStopPlaying:)] )
        [_delegate SoundControllerDidStopPlaying:self];
}

#pragma mark - Public
- (MSound *)sound
{
    if( _sound != nil )
        return _sound;
    
    if( _soundIndex < [_sounds count] )
        return [_sounds objectAtIndex:_soundIndex];
    
    return nil;
}

- (BOOL)isPlaying
{
    return self.sound.isPlaying;
}

- (void)pause
{
    [_audioPlayer pause];
}

- (void)resume
{
    [_audioPlayer play];
}

- (void)stop
{
    if( _titleButton.selected )
        [self play:nil];
}

- (void)enable:(BOOL)b
{
    _titleButton.enabled = b;
}

- (void)purchased
{
    _isInPurchasing = NO;
    
    if( _sound != nil )
        _sound.isUsable = YES;
    else if( _sounds != nil )
    {
        if( _soundIndex < [_sounds count] )
        {
            MSound * theSound = [_sounds objectAtIndex:_soundIndex];
            theSound.isUsable = YES;
            
            [_sounds removeObjectAtIndex:_soundIndex];
            _soundIndex = 0;
        }
    }
}

- (void)startAnimate
{
    if( _timer != nil )
        self.timer = nil;
        
    self.soundIndex = 0;
    if( [self.sounds count] > 1 )
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)t
{
    NSInteger nTot = [self.sounds count];
    self.soundIndex = (_soundIndex+1)%nTot;
    
    [self loadBackgroundImage];
}

- (void)stopAnimate
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Notification
- (void)appWillEnterForeground:(NSNotification *)notification
{
    [self loadBackgroundImage];
}

@end
