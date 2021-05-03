//
//  MoreAppsViewController.m
//  7 Minute Workout
//
//  Created by Ditriol Wei on 30/7/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MoreAppsViewController.h"
#import "AppDefine.h"
#import "MoreApps.h"

@interface MoreAppsViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView * appBannerImageView;
@property (strong, nonatomic) IBOutlet UIScrollView * appIconScrollView;

@end

@implementation MoreAppsViewController{
    int midWidth;
    int currentPosition;
    
    UIImageView * revShadow;
    UIImageView * revAppIcon;
}

+ (BOOL)availableToOpen
{
    return [[MoreApps sharedInstance] available];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:41.0f/255.0f green:59.0f/255.0f blue:63.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationItem.title = @"More Apps";
    UIBarButtonItem * settingBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clear"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onClose:)];
    settingBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = settingBarButtonItem;
    
    
    [self makeDayViewWithCount];
    currentPosition = -1;
    [_appIconScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self getScrolledPosition:_appIconScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Button Event
- (void)onClose:(id)sender
{
    if( [self.navigationController.viewControllers count] == 1 )
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoiTunes:(id)sender
{
    NSArray * apps = [[MoreApps sharedInstance] availableMoreApps];
    if( currentPosition < [apps count] )
    {
        ZenlabsApp * app = [apps objectAtIndex:currentPosition];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.appURL]];
    }
}

#pragma mark - Scroll

- (void)chnageBanner
{
    NSArray * apps = [[MoreApps sharedInstance] availableMoreApps];
    if( currentPosition < [apps count] )
    {
        ZenlabsApp * app = [apps objectAtIndex:currentPosition];
        
        _appBannerImageView.image = [UIImage imageWithContentsOfFile:[app pathForAppBanner]];
    }
}

- (void)makeDayViewWithCount
{
    if( IS_IPAD )
        midWidth=123;
    else
        midWidth=83;
    
    int x = [UIScreen mainScreen].bounds.size.width/2-midWidth/2;
    
    int tag=0;
    
    NSArray * apps = [[MoreApps sharedInstance] availableMoreApps];
    
    for( int j=0 ; j<[apps count] ; j++ )
    {
        ZenlabsApp * app = [apps objectAtIndex:j];
        NSString * iconPath = [app pathForAppIcon];
        
        if( IS_IPAD )
        {
            UIView * dotView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, midWidth, 140)];
            UIImageView * shadow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreapps-icon-shadow"]];
            [shadow setFrame:CGRectMake((midWidth-85)/2, -5, 85, shadow.frame.size.height)];
            [shadow setTag:tag+100];
            
            if ([self.view viewWithTag:tag+100] !=nil)
                [[self.view viewWithTag:tag+100] removeFromSuperview];
            [dotView addSubview:shadow];
            
            UIImageView * appIcon=[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:iconPath]];
            [appIcon setFrame:CGRectMake(31, 25, 60, 60)];
            [appIcon setTag:tag+300];
            
            if ([self.view viewWithTag:tag+300] !=nil)
                [[self.view viewWithTag:tag+300] removeFromSuperview];
            [dotView addSubview:appIcon];
            [_appIconScrollView addSubview:dotView];

            tag++;
            x += dotView.frame.size.width;
        }
        else
        {
            UIView * dotView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, midWidth, 85)];
            UIImageView * shadow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreapps-icon-shadow"]];
            [shadow setFrame:CGRectMake((midWidth-70)/2, -5, 70, shadow.frame.size.height)];
            [shadow setTag:tag+100];
            
            if ([self.view viewWithTag:tag+100] !=nil)
                [[self.view viewWithTag:tag+100] removeFromSuperview];
            [dotView addSubview:shadow];
            
            UIImageView * appIcon=[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:iconPath]];
            [appIcon setFrame:CGRectMake(16, 19, 50, 50)];
            [appIcon setTag:tag+300];
            if ([self.view viewWithTag:tag+300] !=nil)
                [[self.view viewWithTag:tag+300] removeFromSuperview];
            [dotView addSubview:appIcon];
            [_appIconScrollView addSubview:dotView];
            
            tag++;
            x += dotView.frame.size.width;
        }
    }

    CGSize contentSize = CGSizeMake(x+[UIScreen mainScreen].bounds.size.width/2-midWidth/2, _appIconScrollView.frame.size.height);
    _appIconScrollView.contentSize = contentSize;
}

#pragma mark - ScrollViewDelegates
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pos=[self getScrolledPosition:scrollView];
    [scrollView setContentOffset:CGPointMake(pos*midWidth, 0) animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( !decelerate )
    {
        int pos=[self getScrolledPosition:scrollView];
        [scrollView setContentOffset:CGPointMake(pos*midWidth, 0) animated:YES];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    int pos=[self getScrolledPosition:scrollView];
    [scrollView setContentOffset:CGPointMake(pos*midWidth, 0) animated:YES];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if( !scrollView.isDecelerating )
    {
        int pos=[self getScrolledPosition:scrollView];
        [scrollView setContentOffset:CGPointMake(pos*midWidth, 0) animated:YES];
    }
}

- (int)getScrolledPosition:(UIScrollView*)scrollView
{
    float h=0.5;
    float scrolled=scrollView.contentOffset.x/midWidth;
    int position;
    
    if( scrolled < (h+(int)scrolled) )
        position = (int)scrolled;
    else
        position = (int)scrolled+1;
    
    if( position != currentPosition )
    {
        currentPosition = position;
        
        UIImageView * shadow=(UIImageView *)[self.view viewWithTag:currentPosition+100];
        UIImageView * appIcon=(UIImageView *)[self.view viewWithTag:currentPosition+300];
        
        [UIView animateWithDuration:0.3
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             if( IS_IPAD )
                             {
                                 [shadow setFrame:CGRectMake((midWidth-100)/2, -5, 100, shadow.frame.size.height)];
                                 [appIcon setFrame:CGRectMake(26, 15, 70, 70)];
                             }
                             else
                             {
                                 [shadow setFrame:CGRectMake((midWidth-83)/2, -5, 83, shadow.frame.size.height)];
                                 [appIcon setFrame:CGRectMake(11, 10, 60, 60)];
                             }
                         }
                         completion:nil];
        
        if (revAppIcon==nil)
        {
            revAppIcon=appIcon;
            revShadow=shadow;
        }
        else
        {
            [UIView animateWithDuration:0.3
                                  delay: 0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
                                 if( IS_IPAD )
                                 {
                                     [revShadow setFrame:CGRectMake((midWidth-85)/2, -5, 85, shadow.frame.size.height)];
                                     [revAppIcon setFrame:CGRectMake(31, 25, 60, 60)];
                                 }
                                 else
                                 {
                                     [revShadow setFrame:CGRectMake((midWidth-70)/2, -5, 70, revShadow.frame.size.height)];
                                     [revAppIcon setFrame:CGRectMake(16, 19, 50, 50)];
                                 }
                             }
                             completion:nil];
            
            revAppIcon=appIcon;
            revShadow=shadow;
        }
        
        [self chnageBanner];
    }
    
    return position;
}

@end
