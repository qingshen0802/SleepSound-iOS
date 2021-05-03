//
//  SettingViewController.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 26/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UITableViewController

@end


@interface ShareCellView : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView * shareView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareViewConstraint;
@end

@interface UnlockCellView : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel * secondLabel;
@end