//
//  MSound.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SOUND_FREE      = 0,
    SOUND_MONEY,
    SOUND_VIDEO,
    SOUND_RATE,
    
} SOUND_TYPE;

@interface MSound : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * uniqueId;
@property (strong, nonatomic) NSString * background;
@property (strong, nonatomic) NSString * sound;
@property (assign, nonatomic) float volume;
@property (assign, nonatomic) BOOL isUsable;
@property (assign, nonatomic) SOUND_TYPE type;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionary;

@property (assign, nonatomic) BOOL isPlaying;

@end
