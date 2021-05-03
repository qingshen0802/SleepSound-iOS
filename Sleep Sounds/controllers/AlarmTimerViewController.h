//
//  AlarmTimerViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 19/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwichView.h"

@interface AlarmTimerViewController : UIViewController

@end

@class Alarm;
@interface AlarmCell : UITableViewCell <SwitchViewDelegate>
@property (strong, nonatomic) Alarm * alarm;
@property (strong, nonatomic) IBOutlet UILabel * mainTitleLabel;
@property (strong, nonatomic) IBOutlet SwichView * switchView;
@end