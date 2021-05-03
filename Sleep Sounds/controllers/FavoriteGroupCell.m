//
//  FavoriteGroupCell.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "FavoriteGroupCell.h"
#import "Utils.h"

#define HEIGHT_NAME         40
#define HEIGHT_ITEM         80

@implementation FavoriteGroupCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightOfCellWithImageNum:(NSInteger)num
{
    CGFloat h = HEIGHT_NAME + (num/2)*HEIGHT_ITEM + (num%2==1?HEIGHT_ITEM:0) + (num/2);
    return h;
}

- (void)loadImages:(NSArray *)images forNames:(NSArray *)names
{
    NSArray * subviews = [[NSArray alloc] initWithArray:_containerView.subviews];
    for( UIView * v in subviews )
        [v removeFromSuperview];
    
    if( [images count] != [names count] )
        return;
    
    CGSize s = self.bounds.size;
    CGRect r1 = CGRectMake(0, 0, s.width/2, 80);
    CGRect r2 = CGRectMake(s.width/2+1, 0, s.width/2-1, 80);
    CGRect r3 = CGRectMake(10, 30, s.width/2-20, 20);
    CGRect r4 = CGRectMake(s.width/2+1+10, 30, s.width/2-1-20, 20);
    
    for( NSInteger i = 0 ; i < [images count] ; i++ )
    {
        UIImage * image = [images objectAtIndex:i];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        UILabel * label = [[UILabel alloc] init];
        label.text = [names objectAtIndex:i];
        label.font = [Utils fontMyriadProLightWithSize:16];
        label.textColor = [UIColor whiteColor];
        
        [_containerView addSubview:imageView];
        [_containerView addSubview:label];
        
        if( i % 2 == 0 )
        {
            imageView.frame = r1;
            label.frame = r3;
            
            r1.origin.y += (r1.size.height+1);
            r3.origin.y += (r1.size.height+1);
        }
        else
        {
            imageView.frame = r2;
            label.frame = r4;
            
            r2.origin.y += (r2.size.height+1);
            r4.origin.y += (r2.size.height+1);
        }
    }
    
    //_scrollView.contentSize = CGSizeMake(s.width, r1.origin.y);
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
