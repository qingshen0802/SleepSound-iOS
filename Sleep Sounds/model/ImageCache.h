//
//  ImageCache.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 24/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+ (ImageCache *)sharedInstance;

@property (strong, nonatomic) NSString * resourcePath;
- (UIImage *)imageNamed:(NSString *)name;
- (void)clearCache;

@end
