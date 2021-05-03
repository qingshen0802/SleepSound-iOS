//
//  Favorite.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

+ (NSArray *)availableFavorites;
+ (void)saveFavorites:(NSArray *)fs;
+ (Favorite *)favoriteForUniqueId:(NSString *)uid;

@property (strong, nonatomic) NSString * uniqueId;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSMutableArray * soundIds;

- (id)initWithDictionary:(NSDictionary *)d;

- (NSDictionary *)dictionary;

@end
