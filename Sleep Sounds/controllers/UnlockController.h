//
//  UnlockController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 14/12/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreManager.h"

#define kNotificationDidReceiveProductInfo          @"Notification:DidReceiveProductInfo"
#define kNotificationDidPurchaseProduct             @"Notification:DidPurchaseProduct"

@interface UnlockController : UIViewController

+ (UnlockController *)sharedInstance;

@property (assign, nonatomic) BOOL isBusy;

@property (strong, nonatomic) MProduct * unlockForever;
@property (strong, nonatomic) MProduct * unlock3Months;
@property (strong, nonatomic) MProduct * unlock1Month;

- (BOOL)isUnlocked;

- (void)buyUnlockForever;
- (void)buyUnlock3Months;
- (void)buyUnlock1Month;

- (void)restore;

@end
