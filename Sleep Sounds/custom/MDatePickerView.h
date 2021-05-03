//
//  MDatePickerView.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 28/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIME_PICKER_MODE        1
#define COUNTDOWN_PICKER_MODE   2

@protocol MDatePickerViewDelegate;
@interface MDatePickerView : UIPickerView

@property (assign, nonatomic) id<MDatePickerViewDelegate> datePickerViewDelegate;
@property (assign, nonatomic) NSInteger pickerMode;
@property (assign, nonatomic) NSInteger hour;       //[1, 12]
@property (assign, nonatomic) NSInteger minute;     //[0, 59]
@property (assign, nonatomic) NSInteger ampm;       //[0, 1]
@property (assign, nonatomic) NSInteger countdown;
@end

@protocol MDatePickerViewDelegate <NSObject>
@optional
- (void)timeChanged:(MDatePickerView *)pickerView;
- (void)countdownChanged:(MDatePickerView *)pickerView;
@end