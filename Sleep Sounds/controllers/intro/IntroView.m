//
//  IntroView.m
//  7 Minute Workout
//
//  Created by Ditriol Wei on 1/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "IntroView.h"
#import "AppDefine.h"

@interface IntroView ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation IntroView

+ (void)show
{
    IntroView * view = [IntroView view];
    [view show];
}

+ (IntroView *)view
{
    IntroView * view = [[[NSBundle mainBundle] loadNibNamed:@"IntroView" owner:nil options:nil] objectAtIndex:0];
    return view;
}

- (void)show
{
    id<UIApplicationDelegate> a = [[UIApplication sharedApplication] delegate];
    if( [a respondsToSelector:@selector(window)] )
    {
        UIWindow *window = [a window];
        
        self.alpha = 0;
        
        [window addSubview:self];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            if( _delegate!=nil && [_delegate respondsToSelector:@selector(introViewDidShow:)] )
                [_delegate introViewDidShow:self];
        }];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setAutoresizesSubviews:YES];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin    |
                                UIViewAutoresizingFlexibleRightMargin   |
                                UIViewAutoresizingFlexibleTopMargin     |
                                UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSString * imageName = nil;
    if( IS_IPAD )
        imageName = @"intro-ipad";
    else if( IS_IPHONE_5 )
        imageName = @"intro-iphone5";
    else if( IS_IPHONE_6 )
        imageName = @"intro-iphone6";
    else if( IS_IPHONE_6P )
        imageName = @"intro-iphone6p";
    else
        imageName = @"intro-iphone4s";
    
    if( imageName != nil )
    {
        NSString * imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        self.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
}

- (IBAction)onClose:(id)sender
{
    if( !self.superview )
        return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                         [self removeFromSuperview];
                         
                         if( _delegate!=nil && [_delegate respondsToSelector:@selector(introViewDidClose:)] )
                             [_delegate introViewDidClose:self];
                     }];
}

@end
