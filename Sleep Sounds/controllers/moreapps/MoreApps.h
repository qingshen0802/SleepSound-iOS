//
//  MoreApps.h
//  7 Minute Workout
//
//  Created by Ditriol Wei on 30/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TipInfo;
@interface MoreApps : NSObject

+ (MoreApps *)sharedInstance;

- (BOOL)available;
- (NSArray *)availableMoreApps;
- (NSArray *)availableFeaturedAppps;
- (void)updateMoreAppsInfo;

- (BOOL)tipScreenAvailable;
- (TipInfo *)tipInfo;

@end


@interface ZenlabsApp : NSObject

@property (strong, nonatomic) NSString * uniqueId;
@property (strong, nonatomic) NSString * appName;
@property (strong, nonatomic) NSString * appURL;
@property (strong, nonatomic) NSString * appIconURL;
@property (strong, nonatomic) NSString * appBannerURL;

- (NSString *)pathForAppIcon;
- (NSString *)pathForAppBanner;


- (id)initWithUniqueId:(NSString *)uId Dictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionary;
- (void)removeDownloaded;
- (void)download;

@end


@interface TipInfo : NSObject

@property (strong, nonatomic) NSArray * tips;
@property (strong, nonatomic) NSArray * quotes;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionary;

- (NSString *)randomTip;
- (NSString *)randomQuote;

@end


@interface FeaturedApp : NSObject
@property (strong, nonatomic) NSString * uniqueId;
@property (strong, nonatomic) NSString * appDescription;
@property (strong, nonatomic) NSString * appName;
@property (strong, nonatomic) NSString * appURL;
@property (strong, nonatomic) NSString * appIconURL;
- (NSString *)pathForAppIcon;

- (id)initWithUniqueId:(NSString *)uId Dictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionary;
- (void)removeDownloaded;
- (void)download;

@end
