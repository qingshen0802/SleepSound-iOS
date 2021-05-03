//
//  AppDefine.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 26/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#ifndef Sleep_Sounds_AppDefine_h
#define Sleep_Sounds_AppDefine_h

#define APP_NAME        @"Sleep Sounds by Zen Labs Fitness"

#define AppURL          @"https://itunes.apple.com/app/id1043666505"

#define SCREEN_WIDTH            ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT           ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH       (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5             (SCREEN_MAX_LENGTH == 568)
#define IS_IPHONE_6             (SCREEN_MAX_LENGTH == 667)
#define IS_IPHONE_6P            (SCREEN_MAX_LENGTH == 736)


#define MoreAppEnabled          @"MoreAppEnabled"
#define TipScreenEnabled        @"TipScreenEnabled"

#define kAlarmFireNotification              @"Notification:AlarmFire"
#define kAlarmCountDownNotification         @"Notification:AlarmCountDown"
#define kAlarmActiveNotification            @"Notification:AlarmActive"

#define kIntroScreenNotification            @"Notification:IntroScreen"


//Facebook
#define kFacebookLink                       @"https://www.facebook.com/zenlabsfitness"
#define kFacebookId                         @"343577675683891"

//Twitter
#define kTwitterLink                        @"https://twitter.com/zenlabsfitness"
#define kTwitterId                          @"zenlabsfitness"

//Instagram
#define kInstagramLink                      @"https://www.instagram.com/zenlabsfitness"
#define kInstagramId                        @"zenlabsfitness"

#endif
