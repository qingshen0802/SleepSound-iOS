//
//  IntroView.h
//  7 Minute Workout
//
//  Created by Ditriol Wei on 1/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntroViewDelegate;
@interface IntroView : UIView

+ (void)show;

+ (IntroView *)view;
@property (strong, nonatomic) id<IntroViewDelegate> delegate;
- (void)show;

@end

@protocol IntroViewDelegate <NSObject>
@optional
- (void)introViewDidShow:(IntroView *)view;
- (void)introViewDidClose:(IntroView *)view;
@end