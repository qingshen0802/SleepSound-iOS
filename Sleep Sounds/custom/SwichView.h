//
//  SwichView.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchViewDelegate;
@interface SwichView : UIView

@property (assign, nonatomic) id<SwitchViewDelegate> delegate;
@property (assign, nonatomic) BOOL isOn;

@end

@protocol SwitchViewDelegate <NSObject>
@optional
- (void)switchValueChanged:(SwichView *)switchView;
@end