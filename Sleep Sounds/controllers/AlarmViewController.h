//
//  AlarmViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwichView.h"
#import "AlarmManager.h"

#define ALARM_NEW       0
#define ALARM_EDIT      1

@interface AlarmViewController : UIViewController
@property (assign, nonatomic) NSInteger mode;
@property (strong, nonatomic) Alarm * alarm;
@end

@interface AlarmPropertyCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel * subTitleLabel;
@property (strong, nonatomic) IBOutlet SwichView * switchView;
@end