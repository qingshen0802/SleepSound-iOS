//
//  FavoriteEditViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favorite.h"

@protocol FavoriteEditViewControllerDelegate;

@interface FavoriteEditViewController : UIViewController
@property (assign, nonatomic) id<FavoriteEditViewControllerDelegate> delegate;
@property (strong, nonatomic) Favorite * favorite;
@property (assign, nonatomic) BOOL isEdit;          //YES: Edit, NO: Add

@end


@protocol FavoriteEditViewControllerDelegate <NSObject>
@optional
- (void)favoriteEditViewControllerDidChange:(FavoriteEditViewController *)controller;
@end