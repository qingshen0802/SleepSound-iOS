//
//  Favorite.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "Favorite.h"
#import "Utils.h"
#import "MSoundManager.h"

#define FAVORITE_FILE       @"Favorite.plist"

@implementation Favorite

+ (NSArray *)availableFavorites;
{
    NSMutableArray * a = [NSMutableArray array];
    
    NSString * path = [Favorite pathForFavorites];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path] )
        path = [Favorite pathForDefaultFavorites];
        
    NSMutableArray * fa = [NSMutableArray arrayWithContentsOfFile:path];
    for( NSDictionary * d in fa )
    {
        Favorite * f = [[Favorite alloc] initWithDictionary:d];
        [a addObject:f];
    }
    
    return a;
}

+ (void)saveFavorites:(NSArray *)fa
{
    NSMutableArray * fda = [NSMutableArray array];
    for( Favorite * f in fa )
        [fda addObject:[f dictionary]];
    
    [fda writeToFile:[Favorite pathForFavorites] atomically:YES];
}

+ (NSString *)pathForFavorites
{
    return [[Utils pathOfDocument] stringByAppendingPathComponent:FAVORITE_FILE];
}

+ (NSString *)pathForDefaultFavorites
{
    NSString * path = [[NSBundle mainBundle] pathForResource:FAVORITE_FILE ofType:nil];
    return path;
}

+ (Favorite *)favoriteForUniqueId:(NSString *)uid
{
    NSArray * favorites = [self availableFavorites];
    for( Favorite * f in favorites )
    {
        if( [f.uniqueId isEqualToString:uid] )
            return f;
    }
    
    return nil;
}

- (NSString *)uniqueId
{
    if( _uniqueId == nil )
        self.uniqueId = [Utils uniqueId];
    return _uniqueId;
}

#pragma mark - Favorite

- (id)initWithDictionary:(NSDictionary *)d
{
    self = [super init];
    if( self != nil )
    {
        self.uniqueId = [d objectForKey:@"uniqueId"];
        self.name = [d objectForKey:@"name"];
        self.soundIds = [NSMutableArray array];
        
        NSArray * ids = [d objectForKey:@"soundIds"];
        if( ids!=nil || [ids isKindOfClass:[NSArray class]] )
            [_soundIds addObjectsFromArray:ids];
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];

    [d setObject:self.uniqueId forKey:@"uniqueId"];
    
    if( _name != nil )
        [d setObject:_name forKey:@"name"];

    if( _soundIds != nil )
        [d setObject:_soundIds forKey:@"soundIds"];
    
    return d;
}

@end
