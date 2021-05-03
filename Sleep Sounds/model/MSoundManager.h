//
//  MSoundManager.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSound.h"

@interface MSoundManager : NSObject

+ (MSoundManager *)sharedInstance;

+ (void)activeAudioSession:(BOOL)active;

- (void)loadSounds;
- (void)saveSounds;
- (void)restoreSounds;

- (NSArray *)purchasedSounds;
- (NSArray *)notPurchasedSounds;
- (NSArray *)videoPurchaseSounds;
- (NSArray *)playingSounds;

- (NSArray *)soundForRate;
- (MSound *)soundForId:(NSString *)Id;

#pragma mark - Path
+ (NSString *)pathOfResources;

@end
