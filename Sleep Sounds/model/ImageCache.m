//
//  ImageCache.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 24/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache ()
@property (strong, nonatomic) NSMutableDictionary * images;
@end

@implementation ImageCache

+ (ImageCache *)sharedInstance
{
    static dispatch_once_t onceToken;
    static ImageCache * imageCacheSharedInstance;
    
    dispatch_once(&onceToken, ^{
        imageCacheSharedInstance = [[ImageCache alloc] init];
    });
    return imageCacheSharedInstance;
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        self.images = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (void)appDidEnterBackground:(NSNotification *)notification
{
    [self clearCache];
}

- (UIImage *)imageNamed:(NSString *)name;
{
    UIImage * image = [_images objectForKey:name];
    if( image == nil )
    {
        NSString * path = [_resourcePath stringByAppendingPathComponent:name];
        image = [UIImage imageWithContentsOfFile:path];
        
        if( image != nil )
            [_images setObject:image forKey:name];
    }
    
    return image;
}

- (void)clearCache
{
    [_images removeAllObjects];
}

@end
