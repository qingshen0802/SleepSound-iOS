//
//  MSound.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MSound.h"
#import "Utils.h"

@implementation MSound

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if( self != nil )
    {
        self.name           = [dic objectForKey:@"name"];
        self.background     = [dic objectForKey:@"background"];
        self.sound          = [dic objectForKey:@"sound"];
        self.uniqueId       = [dic objectForKey:@"uniqueId"];
        self.volume         = [[dic objectForKey:@"volume"] floatValue];
        self.isUsable       = [[dic objectForKey:@"isUsable"] boolValue];
        self.type           = (SOUND_TYPE)[[dic objectForKey:@"type"] integerValue];
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    if( _name != nil )
        [d setObject:_name forKey:@"name"];
    if( _background != nil )
        [d setObject:_background forKey:@"background"];
    if( _sound != nil )
        [d setObject:_sound forKey:@"sound"];
    if( _uniqueId != nil )
        [d setObject:_uniqueId forKey:@"uniqueId"];
    [d setObject:[NSNumber numberWithFloat:_volume] forKey:@"volume"];
    [d setObject:[NSNumber numberWithBool:_isUsable] forKey:@"isUsable"];
    [d setObject:[NSNumber numberWithInteger:_type] forKey:@"type"];
    
    return d;
}

@end
