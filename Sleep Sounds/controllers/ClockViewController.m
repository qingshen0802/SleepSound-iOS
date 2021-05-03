//
//  ClockViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 25/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "ClockViewController.h"

#define background1_portrait    @"clock_background1_portrait.jpg"
#define background2_portrait    @"clock_background2_portrait.jpg"

#define background1_landscape   @"clock_background1_landscape.jpg"
#define background2_landscape   @"clock_background2_landscape.jpg"

@interface ClockViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UIImageView *tipImageView;
@property (strong, nonatomic) IBOutlet UIView *filterView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tipX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tipY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timY;


//Portrait
@property (strong, nonatomic) UIImage * image11;
@property (strong, nonatomic) UIImage * image12;
//Landscape
@property (strong, nonatomic) UIImage * image21;
@property (strong, nonatomic) UIImage * image22;

//Font
@property (strong, nonatomic) UIFont * font1;
@property (strong, nonatomic) UIFont * font2;

@end

@implementation ClockViewController{
    UIImage * images[2][2];
    
    int mod;
    int idx;
    
    UIFont * fonts[2];
    
    CGPoint timXY[2][2];
    CGPoint tipXY[2][2];
    
    NSTimer * timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString * p;
    p = [[NSBundle mainBundle] pathForResource:background1_portrait ofType:@""];
    self.image11 = [UIImage imageWithContentsOfFile:p];
    p = [[NSBundle mainBundle] pathForResource:background2_portrait ofType:@""];
    self.image12 = [UIImage imageWithContentsOfFile:p];
    p = [[NSBundle mainBundle] pathForResource:background1_landscape ofType:@""];
    self.image21 = [UIImage imageWithContentsOfFile:p];
    p = [[NSBundle mainBundle] pathForResource:background2_landscape ofType:@""];
    self.image22 = [UIImage imageWithContentsOfFile:p];
    
    //Portrait
    images[0][0] = _image11; images[0][1] = _image12;
    //Landscape
    images[1][0] = _image21; images[1][1] = _image22;
    
    self.font1 = [UIFont fontWithName:@"DigitalDreamFat" size:50];
    self.font2 = [UIFont fontWithName:@"DIN-Light" size:70];
    fonts[0] = _font1;
    fonts[1] = _font2;
    
    
    timXY[0][0] = CGPointMake(0.5, 0.8);
    timXY[0][1] = CGPointMake(0.5, 0.5);
    timXY[1][0] = CGPointMake(0.75, 0.8);
    timXY[1][1] = CGPointMake(0.5, 0.5);
    
    tipXY[0][0] = CGPointMake(0.5, 0.2);
    tipXY[0][1] = CGPointMake(0.5, 0.83);
    tipXY[1][0] = CGPointMake(0.5, 0.25);
    tipXY[1][1] = CGPointMake(0.1, 0.5);
    
    [self displayTime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if( UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) )
    {
        mod = 0;
        idx = 0;
    }
    else
    {
        mod = 1;
        idx = 0;
    }
    
    [self changeBackgroundAnimated:NO];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTimer:(NSTimer *)t
{
    [self displayTime];
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    [self displayTime];
}

- (void)displayTime
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    _timeLabel.text = [formatter stringFromDate:[NSDate date]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Orientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //For iOS 7
    NSLog(@"willRotateToInterfaceOrientation");
    [self adjustBackgroundOnMode:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    //For iOS 8
    NSLog(@"viewWillTransition");
    BOOL isPortrait = (size.height > size.width);
    [self adjustBackgroundOnMode:isPortrait];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)adjustBackgroundOnMode:(BOOL)isPortrait
{
    if( isPortrait )
        mod = 0;        //Portrait
    else
        mod = 1;        //Landscape
    
    [self changeBackgroundAnimated:NO];
}

- (CGSize)winSize
{
    CGSize s = [UIScreen mainScreen].bounds.size;
    CGSize winSize;
    
    if( mod == 0 )
    {
        //Portrait
        winSize.width   = MIN(s.width, s.height);
        winSize.height  = MAX(s.width, s.height);
    }
    else
    {
        //Landscape
        winSize.width   = MAX(s.width, s.height);
        winSize.height  = MIN(s.width, s.height);
    }
    
    return winSize;
}

- (void)changeBackgroundAnimated:(BOOL)isAnimated
{
    if( isAnimated )
    {
        [UIView transitionWithView:_backImageView
                          duration:0.6
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _backImageView.image = images[mod][idx];
                            CGSize s = [self winSize];
                            _timX.constant = timXY[mod][idx].x*s.width-CGRectGetWidth(_timeLabel.bounds)/2;
                            _timY.constant = timXY[mod][idx].y*s.height-CGRectGetHeight(_timeLabel.bounds)/2;
                            _tipX.constant = tipXY[mod][idx].x*s.width-CGRectGetWidth(_tipImageView.bounds)/2;
                            _tipY.constant = tipXY[mod][idx].y*s.height-CGRectGetHeight(_tipImageView.bounds)/2;
                            
                            [self.view layoutIfNeeded];
                        }
                        completion:^(BOOL finished) {
                            _timeLabel.font = fonts[idx];
                        }];
    }
    else
    {
        _backImageView.image = images[mod][idx];
        CGSize s = [self winSize];
        _timX.constant = timXY[mod][idx].x*s.width-CGRectGetWidth(_timeLabel.bounds)/2;
        _timY.constant = timXY[mod][idx].y*s.height-CGRectGetHeight(_timeLabel.bounds)/2;
        _tipX.constant = tipXY[mod][idx].x*s.width-CGRectGetWidth(_tipImageView.bounds)/2;
        _tipY.constant = tipXY[mod][idx].y*s.height-CGRectGetHeight(_tipImageView.bounds)/2;
        _timeLabel.font = fonts[idx];
    }
}

#pragma mark - Gesture Actions
- (IBAction)onTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onRight:(id)sender
{
    idx = (++idx%2);
    [self changeBackgroundAnimated:YES];
}

- (IBAction)onLeft:(id)sender
{
    idx = (++idx%2);
    [self changeBackgroundAnimated:YES];
}

- (IBAction)onUp:(id)sender
{
    CGFloat alpha = _filterView.alpha - 0.2;
    if( alpha < 0  )
        alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _filterView.alpha = alpha;
    }];
}

- (IBAction)onDown:(id)sender
{
    CGFloat alpha = _filterView.alpha + 0.2;
    if( alpha > 0.8  )
        alpha = 0.8;
    [UIView animateWithDuration:0.3 animations:^{
        _filterView.alpha = alpha;
    }];
}

@end
