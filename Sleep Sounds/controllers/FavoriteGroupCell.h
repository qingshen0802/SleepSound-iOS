//
//  FavoriteGroupCell.h
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteGroupCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView * checkmark;

+ (CGFloat)heightOfCellWithImageNum:(NSInteger)num;

- (void)loadImages:(NSArray *)images forNames:(NSArray *)names;

@end
