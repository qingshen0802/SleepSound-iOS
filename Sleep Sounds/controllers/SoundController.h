//
//  SoundController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSound.h"

@protocol SoundControllerDelegate;
@interface SoundController : UIViewController

@property (strong, nonatomic) MSound * sound;
@property (strong, nonatomic) NSMutableArray * sounds;
@property (assign, nonatomic) NSInteger soundIndex;

- (id)initWithSound:(MSound *)s;
- (id)initWithSounds:(NSArray *)ss;
- (MSound *)sound;

- (BOOL)isPlaying;
- (void)pause;
- (void)resume;
- (void)stop;

- (IBAction)play:(id)sender;

@property (assign, nonatomic) id<SoundControllerDelegate> delegate;

- (void)enable:(BOOL)b;
@property (assign, nonatomic) BOOL isInPurchasing;
- (void)purchased;

- (void)startAnimate;
- (void)stopAnimate;

@end


@protocol SoundControllerDelegate <NSObject>
- (void)SoundControllerDidStartPlaying:(SoundController *)controller;
- (void)SoundControllerDidStopPlaying:(SoundController *)controller;
- (void)SoundControllerPlayingVideoAd:(SoundController *)controller;
- (void)SoundControllerRate:(SoundController *)controller;
- (void)SoundControllerUnlockAll:(SoundController *)controller;
@end