//
//  MoreApps.m
//  7 Minute Workout
//
//  Created by Ditriol Wei on 30/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MoreApps.h"
#import "Utils.h"
#import "AppDefine.h"

#define MoreAppFolder           @"moreapps"
#define MoreAppInfoFile         @"moreappinfo.plist"
#define MoreAppFeedURL          @"http://c25kfree.com/config/WSLMoreAppsData_C25Knew.plist"
#define MoreAppTipFile          @"tip.plist"
#define MoreAppFeaturedFile     @"featured.plist"
#define MoreAppLastUpdatedDate  @"MoreAppLastUpdated"

#pragma mark - MoreApps
@implementation MoreApps{
    BOOL isInUpdating;
}

+ (MoreApps *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MoreApps * moreappsSharedInstance;
    
    dispatch_once(&onceToken, ^{
        moreappsSharedInstance = [[MoreApps alloc] init];
    });
    return moreappsSharedInstance;
}

- (BOOL)available
{
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:MoreAppEnabled] )
        return NO;
    
    NSString * plist = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppInfoFile];
    if( [[NSFileManager defaultManager] fileExistsAtPath:plist] && !isInUpdating )
        return YES;
    return NO;
}

- (NSArray *)availableMoreApps
{
    NSMutableArray * apps = [NSMutableArray array];
    
    NSString * plist = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppInfoFile];
    NSArray * appInfo = [NSArray arrayWithContentsOfFile:plist];
    for( NSDictionary * dic in appInfo )
    {
        ZenlabsApp * app = [[ZenlabsApp alloc] initWithUniqueId:nil Dictionary:dic];
        [apps addObject:app];
    }
    
    return apps;
}

- (NSArray *)availableFeaturedAppps
{
    NSMutableArray * apps = [NSMutableArray array];
    
    NSString * plist = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppFeaturedFile];
    NSArray * appInfo = [NSArray arrayWithContentsOfFile:plist];
    for( NSDictionary * dic in appInfo )
    {
        FeaturedApp * app = [[FeaturedApp alloc] initWithUniqueId:nil Dictionary:dic];
        [apps addObject:app];
    }
    
    return apps;
}

- (BOOL)tipScreenAvailable
{
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:TipScreenEnabled] )
        return NO;
    
    return [self available];
}

- (TipInfo *)tipInfo
{
    NSDictionary * plist = [NSDictionary dictionaryWithContentsOfFile:[[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppTipFile]];
    TipInfo * tip = [[TipInfo alloc] initWithDictionary:plist];
    return tip;
}

- (void)updateMoreAppsInfo
{
    NSDate * lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:MoreAppLastUpdatedDate];
    if( lastDate == nil || [[NSDate date] timeIntervalSinceDate:lastDate] > 3*24*60*60 )
        [NSThread detachNewThreadSelector:@selector(doUpdateMoreAppsInfo:) toTarget:self withObject:nil];
}

- (void)doUpdateMoreAppsInfo:(id)arg
{
    NSLog(@"Start downloading MoreAppInfo.");
    isInUpdating = YES;
    
    NSDictionary * plist = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:MoreAppFeedURL]];
    if( plist != nil )
    {
        NSArray * apps;

        //More Apps
        apps = [plist objectForKey:@"apps"];
        if( apps != nil )
        {
            [self removeMoreApps];
            
            NSMutableArray * newPlist = [NSMutableArray array];
            
            for( int i = 0 ; i < [apps count] ; i++ )
            {
                NSString * idx = [NSString stringWithFormat:@"%d", i];
                NSDictionary * dic = [apps objectAtIndex:i];
                
                ZenlabsApp * app = [[ZenlabsApp alloc] initWithUniqueId:idx Dictionary:dic];
                [app download];
                
                [newPlist addObject:[app dictionary]];
            }
            
            NSString * plistPath = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppInfoFile];
            [newPlist writeToFile:plistPath atomically:YES];
        }

        //Featured Apps
        apps = [plist objectForKey:@"featured"];
        if( apps != nil )
        {
            [self removeFeaturedApps];
            
            NSMutableArray * newPlist = [NSMutableArray array];
            
            for( int i = 0 ; i < [apps count] ; i++ )
            {
                NSString * idx = [NSString stringWithFormat:@"%d", i];
                NSDictionary * dic = [apps objectAtIndex:i];
                
                FeaturedApp * app = [[FeaturedApp alloc] initWithUniqueId:idx Dictionary:dic];
                [app download];
                
                [newPlist addObject:[app dictionary]];
            }
            
            NSString * plistPath = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppFeaturedFile];
            [newPlist writeToFile:plistPath atomically:YES];
        }
        
        //Tip Screen Info
        TipInfo * tip = [[TipInfo alloc] initWithDictionary:plist];
        NSString * tipPath = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppTipFile];
        [[tip dictionary] writeToFile:tipPath atomically:YES];
        
        //Enabled
        BOOL b = [[plist objectForKey:@"enabled"] boolValue];
        [[NSUserDefaults standardUserDefaults] setBool:b forKey:MoreAppEnabled];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:MoreAppLastUpdatedDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    isInUpdating = NO;
    NSLog(@"Finished downloading MoreAppInfo.");
}

- (void)removeMoreApps
{
    NSArray * apps = [self availableMoreApps];
    for( ZenlabsApp * app in apps )
        [app removeDownloaded];
    
    NSString * plist = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppInfoFile];
    if( [[NSFileManager defaultManager] fileExistsAtPath:plist] )
        [[NSFileManager defaultManager] removeItemAtPath:plist error:nil];
}

- (void)removeFeaturedApps
{
    NSArray * apps = [self availableFeaturedAppps];
    for( FeaturedApp * app in apps )
        [app removeDownloaded];
    
    NSString * plist = [[MoreApps pathForMoreApp] stringByAppendingPathComponent:MoreAppFeaturedFile];
    if( [[NSFileManager defaultManager] fileExistsAtPath:plist] )
        [[NSFileManager defaultManager] removeItemAtPath:plist error:nil];
}

+ (NSString *)pathForMoreApp
{
    NSString * moreAppFolder = [[Utils pathOfDocument] stringByAppendingPathComponent:MoreAppFolder];
    BOOL isDir = NO;
    if( ![[NSFileManager defaultManager] fileExistsAtPath:moreAppFolder isDirectory:&isDir] || !isDir )
        [[NSFileManager defaultManager] createDirectoryAtPath:moreAppFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    return moreAppFolder;
}

@end

@implementation ZenlabsApp

- (NSString *)pathForAppIcon
{
    if( self.uniqueId == nil )
        return nil;
    return [[MoreApps pathForMoreApp] stringByAppendingPathComponent:[NSString stringWithFormat:@"appicon_%@.png", _uniqueId]];
}

- (NSString *)pathForAppBanner
{
    if( self.uniqueId == nil )
        return nil;
    return [[MoreApps pathForMoreApp] stringByAppendingPathComponent:[NSString stringWithFormat:@"appbanner_%@.png", _uniqueId]];
}

#pragma mark - Init
- (id)initWithUniqueId:(NSString *)uId Dictionary:(NSDictionary *)dic
{
    self = [super init];
    if( self != nil )
    {
        self.uniqueId       = [dic objectForKey:@"id"];
        self.appName        = [dic objectForKey:@"name"];
        self.appURL         = [dic objectForKey:@"url"];
        self.appIconURL     = [dic objectForKey:@"icon"];
        self.appBannerURL   = [dic objectForKey:[self bannerKey]];
        
        if( self.uniqueId == nil )
            self.uniqueId = uId;
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    
    if( _uniqueId != nil )
        [dic setObject:_uniqueId forKey:@"id"];
    if( _appName != nil )
        [dic setObject:_appName forKey:@"name"];
    if( _appURL != nil )
        [dic setObject:_appURL forKey:@"url"];
    if( _appIconURL != nil )
        [dic setObject:_appIconURL forKey:@"icon"];
    if( _appBannerURL != nil )
        [dic setObject:_appBannerURL forKey:[self bannerKey]];
    
    
    return dic;
}

- (NSString *)bannerKey
{
    NSString * key;
    if( IS_IPAD )
        key = @"banneripad";
    else //if( IS_IPHONE )
    {
        if( IS_IPHONE_5 )
            key = @"banner568";
        else
        {
            if( IS_IPHONE_6 || IS_IPHONE_6P )
                key = @"banner6";
            else
                key = @"banner";
        }
    }
    return key;
}

- (void)removeDownloaded
{
    //icon
    NSString * iconPath = [self pathForAppIcon];
    if( iconPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:iconPath] )
        [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
    
    //banner
    NSString * bannerPath = [self pathForAppBanner];
    if( bannerPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:bannerPath] )
        [[NSFileManager defaultManager] removeItemAtPath:bannerPath error:nil];
}

- (void)download
{
    //icon
    if( _appIconURL != nil )
    {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_appIconURL]];
        if( data != nil )
            [data writeToFile:[self pathForAppIcon] atomically:YES];
    }
    
    //banner
    if( _appBannerURL != nil )
    {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_appBannerURL]];
        if( data != nil )
            [data writeToFile:[self pathForAppBanner] atomically:YES];
    }
}

@end


@implementation TipInfo

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    
    if( self != nil )
    {
        NSArray * array;
        
        //Tips
        array = [dic objectForKey:@"tips"];
        if( array != nil && [array isKindOfClass:[NSArray class]] )
            self.tips = [[NSArray alloc] initWithArray:array];
        
        //Quotes
        array = [dic objectForKey:@"quotes"];
        if( array != nil && [array isKindOfClass:[NSArray class]] )
            self.quotes = [[NSArray alloc] initWithArray:array];
        
        srand((unsigned int)time(NULL));
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    if( _tips != nil )
        [d setObject:_tips forKey:@"tips"];
    if( _quotes != nil )
        [d setObject:_quotes forKey:@"quotes"];
    
    return d;
}

- (NSString *)randomTip
{
    NSString * tip;
    if( [_tips count] > 0 )
    {
        int idx = rand()%[_tips count];
        tip = [_tips objectAtIndex:idx];
    }
    else
    {
        tip = @"";
    }
    
    return tip;
}

- (NSString *)randomQuote
{
    NSString * quote;
    if( [_quotes count] > 0 )
    {
        int idx = rand()%[_quotes count];
        quote = [_quotes objectAtIndex:idx];
    }
    else
    {
        quote = @"";
    }
    
    return quote;
}

@end

@implementation FeaturedApp

- (NSString *)pathForAppIcon
{
    return [[MoreApps pathForMoreApp] stringByAppendingPathComponent:[NSString stringWithFormat:@"featured_%@.png", _uniqueId]];
}

- (id)initWithUniqueId:(NSString *)uId Dictionary:(NSDictionary *)dic
{
    self = [super init];
    if( self !=nil )
    {
        self.uniqueId       = [dic objectForKey:@"id"];
        self.appDescription = [dic objectForKey:@"description"];
        self.appName        = [dic objectForKey:@"name"];
        self.appURL         = [dic objectForKey:@"url"];
        self.appIconURL     = [dic objectForKey:@"icon"];
        
        if( _uniqueId == nil )
            self.uniqueId = uId;
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    if( _uniqueId != nil )
        [d setObject:_uniqueId forKey:@"id"];
    if( _appDescription != nil )
        [d setObject:_appDescription forKey:@"description"];
    if( _appName != nil )
        [d setObject:_appName forKey:@"name"];
    if( _appURL != nil )
        [d setObject:_appURL forKey:@"url"];
    if( _appIconURL != nil )
        [d setObject:_appIconURL forKey:@"icon"];
    
    return d;
}

- (void)removeDownloaded
{
    NSString * iconPath = [self pathForAppIcon];
    if( [[NSFileManager defaultManager] fileExistsAtPath:iconPath] )
        [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
}

- (void)download
{
    if( _appIconURL != nil )
    {
        NSData * iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_appIconURL]];
        if( iconData != nil )
        {
            NSString * iconPath = [self pathForAppIcon];
            [iconData writeToFile:iconPath atomically:YES];
        }
    }
}

@end