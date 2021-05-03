//
//  RateViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 5/2/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSound.h"

#define kNotification_UserRated         @"Notification:UserRated"

@interface RateViewController : UIViewController

+ (BOOL)userRated;

@end
