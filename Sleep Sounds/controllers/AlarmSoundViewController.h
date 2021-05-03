//
//  AlarmSoundViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 29/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Alarm;
@interface AlarmSoundViewController : UIViewController
@property (strong, nonatomic) Alarm * alarm;
@end

@interface UseCurrentMixSelectionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *checkmark;
@end