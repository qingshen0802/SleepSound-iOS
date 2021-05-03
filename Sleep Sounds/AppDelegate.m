//
//  AppDelegate.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 25/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "MSoundManager.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import "ImageCache.h"
#import "MoreApps.h"
#import <VungleSDK/VungleSDK.h>
#import "AlarmManager.h"
#import "UnlockController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //Video Ad
    NSString* appID = @"566eb9cb285af3ee7f000012";
    VungleSDK *sdk = [VungleSDK sharedSDK];
    [sdk startWithAppId:appID];
    
    [[MSoundManager sharedInstance] loadSounds];
    if( ![[UnlockController sharedInstance] isUnlocked] )
        [[MSoundManager sharedInstance] restoreSounds];
    
    [[ImageCache sharedInstance] setResourcePath:[MSoundManager pathOfResources]];
    
    //UI Setting
    SWRevealViewController * revealController = (SWRevealViewController *)_window.rootViewController;
    if( [revealController isKindOfClass:[SWRevealViewController class]] )
        revealController.rightViewRevealWidth = _window.bounds.size.width - ([Utils isIPHONE]?50:60);
    
    //MoreAppInfo
    [[MoreApps sharedInstance] updateMoreAppsInfo];
    
    //Alarm Manager
    [AlarmManager sharedInstance];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
