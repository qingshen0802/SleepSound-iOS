//
//  DashbaordViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 26/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "DashbaordViewController.h"
#import "SWRevealViewController.h"
#import "MSoundManager.h"
#import "MSound.h"
#import "SoundController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FavoritesViewController.h"
#import "Favorite.h"
#import "AppDefine.h"
#import "UnlockController.h"
#import <VungleSDK/VungleSDK.h>
#import "AlarmManager.h"
#import "RateViewController.h"
#import "IntroView.h"
#import <iAd/iAd.h>
#import "SubscribeViewController.h"
#import "WSLMoreAppsView.h"
#import "MoreApps.h"

#define SOUND_VIEW_HEIGHT       80

@interface DashbaordViewController () <SoundControllerDelegate, VungleSDKDelegate, ADBannerViewDelegate, WSLMoreAppsViewDelegate>{

    IBOutlet NSLayoutConstraint *bottomConstraions;
}
@property (strong, nonatomic) WSLMoreAppsView * tipScreen;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *revealLeftButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *revealRightButtonItem;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *pause_resumeButton;
@property (strong, nonatomic) IBOutlet UIButton *volumeButton;
@property (strong, nonatomic) IBOutlet UIView *volumeControlView;
@property (strong, nonatomic) IBOutlet UIView *volumeControlContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *volumeControlViewConstraint;

@property (strong, nonatomic) IBOutlet UIView *alarmTimeView;
@property (strong, nonatomic) IBOutlet UILabel *alarmTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *alarmTimeImageView;

@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;

@property (strong, nonatomic) NSMutableArray * purchasedSoundControllers;
@property (strong, nonatomic) NSMutableArray * notPurchasedSoundControllers;
@property (strong, nonatomic) SoundController * videoWatchSoundController;
@property (strong, nonatomic) SoundController * rateSoundController;
@property (assign, nonatomic) BOOL isLoaded;
@property (assign, nonatomic) BOOL isNeedReload;
@property (strong, nonatomic) IntroView * introView;

@property (assign, nonatomic) BOOL isSplashLoaded;
@property (assign, nonatomic) BOOL isHelpLoaded;
@end

@implementation DashbaordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SWRevealViewController *revealViewController = self.revealViewController;
    if( revealViewController )
    {
        [revealViewController tapGestureRecognizer];
        [self.revealLeftButtonItem setTarget: self.revealViewController];
        [self.revealLeftButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        
        [self.revealRightButtonItem setTarget:self.revealViewController];
        [self.revealRightButtonItem setAction:@selector(rightRevealToggle:)];
    }

    //UI Init
    [self initVolumeControlView];
    
    //Sound Init
    NSArray * purchasedSounds = [[MSoundManager sharedInstance] purchasedSounds];
    self.purchasedSoundControllers = [NSMutableArray array];
    for( MSound * s in purchasedSounds )
    {
        SoundController * controller = [[SoundController alloc] initWithSound:s];
        [controller setDelegate:self];
        [_purchasedSoundControllers addObject:controller];
    }
    
    NSArray * notPurchasedSounds = [[MSoundManager sharedInstance] notPurchasedSounds];
    self.notPurchasedSoundControllers = [NSMutableArray array];
    for( MSound * s in notPurchasedSounds )
    {
        SoundController * controller = [[SoundController alloc] initWithSound:s];
        [controller setDelegate:self];
        [_notPurchasedSoundControllers addObject:controller];
    }
    
    NSArray * videoWatchSounds = [[MSoundManager sharedInstance] videoPurchaseSounds];
    if( [videoWatchSounds count] > 0 )
    {
        self.videoWatchSoundController = [[SoundController alloc] initWithSounds:videoWatchSounds];
        [self.videoWatchSoundController setDelegate:self];
        [self.videoWatchSoundController startAnimate];
        [self.notPurchasedSoundControllers addObject:self.videoWatchSoundController];
    }

    NSArray * rateSounds = [[MSoundManager sharedInstance] soundForRate];
    self.rateSoundController = [[SoundController alloc] initWithSounds:rateSounds];
    [self.rateSoundController setDelegate:self];
    [self.rateSoundController startAnimate];
    
    //version 1.1
//     NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1043666505"];
//    if ((![[[NSUserDefaults standardUserDefaults] objectForKey:@"RateSound"] isEqualToString:@"rated"]) && ([[UIApplication sharedApplication] canOpenURL:url])) {
//        [self.notPurchasedSoundControllers addObject:self.rateSoundController];
//    }

    /*
    if( [RateViewController userRated] )
    {
        MSound * s = [[MSoundManager sharedInstance] soundForRate];
        s.isUsable = YES;
        SoundController * controller = [[SoundController alloc] initWithSound:s];
        [controller setDelegate:self];
        [_purchasedSoundControllers addObject:controller];
    }
     */
     
    if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"IntroIsShown"] )
        [self performSelector:@selector(showIntro) withObject:nil afterDelay:4.5];
    else [self addIADBanner];
    
    
    //Register Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayFavorite:)
                                                 name:kNotificatonPlayFavorite
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alarmActive:)
                                                 name:kAlarmActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alarmFire:)
                                                 name:kAlarmFireNotification
                                               object:nil];
    
    if( ![RateViewController userRated] )
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserRated:)
                                                 name:kNotification_UserRated
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onIntroScreen:)
                                                 name:kIntroScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUnlockAll:)
                                                 name:kNotificationDidPurchaseProduct
                                               object:nil];
    
    //Alarm Time View
    _alarmTimeView.hidden = YES;
    
    //Init Variable
    _isLoaded = NO;
    _isNeedReload = NO;
    _isHelpLoaded = NO;
    
    //Tip Screen
    [self setTipScreen:[WSLMoreAppsView instance]];
    if( [[MoreApps sharedInstance] tipScreenAvailable] )
    {
        [_tipScreen setDelegate:self];
        [_tipScreen show];
    }
}

-(void)addIADBanner{
    
    if( ![[UnlockController sharedInstance] isUnlocked] ) {
        _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
        _adBanner.delegate = self;
        [self.view addSubview:_adBanner];
        _adBanner.alpha = 0.0;
    }
}

- (void)WSLMoreAppsViewClosed:(WSLMoreAppsView *)view
{
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    //Status Bar - Black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if( !_isLoaded || _isNeedReload )
    {
        [self refresh];
        
        _isLoaded = YES;
        _isNeedReload = NO;
    }
    
    if( !_tipScreen.isOpened )
    {
        [self refresh];
    }
}

- (void)refresh
{
    [self loadControllers];
    [self showControllers];
}

- (void)loadControllers
{
    CGSize s = _scrollView.bounds.size;
    CGFloat h = SOUND_VIEW_HEIGHT;
    CGRect r = CGRectMake(0, 0, s.width, h);
    
    for( NSInteger i = 0 ; i < [_purchasedSoundControllers count] ; i++ )
    {
        SoundController * controller = [_purchasedSoundControllers objectAtIndex:i];
        
        if( controller.view.superview == nil )
        {
            [_scrollView addSubview:controller.view];
            
            if( IS_IPAD )
            {
                r.size.width = s.width/2;
                if( i % 2 == 0 )
                    r.origin.x = -s.width;
                else
                    r.origin.x = -s.width/2;
            }
            else
            {
                r.origin.x = -s.width;
            }
            
            controller.view.frame = r;
        }
        else
        {
            if( IS_IPAD )
            {
                r.size.width = s.width/2;
                if( i % 2 == 0 )
                    r.origin.x = 0;
                else
                    r.origin.x = s.width/2 + 1;
            }
            else
            {
                r.origin.x = 0;
            }
            
            controller.view.frame = r;
        }

        CGFloat o = 1+h;
        
        if( IS_IPAD )
        {
            if( i%2 == 0 && i < [_purchasedSoundControllers count]-1 )
                o = 0;
        }
            
        r.origin.y += o;
    }
    
    if( [_notPurchasedSoundControllers count] > 0 )
    {
        //Unlock View
        UIView * unlockView = [UnlockController sharedInstance].view;
        CGRect ur = unlockView.frame;
        ur.origin.y = r.origin.y;
        ur.size.width = s.width;
        if( unlockView.superview == nil )
        {
            [_scrollView addSubview:unlockView];
            ur.origin.x = -s.width;
            unlockView.frame = ur;
        }
        else
        {
            ur.origin.x = 0;
            unlockView.frame = ur;
        }

        CGFloat w = s.width/2;
        
        r.origin.y += (1+unlockView.bounds.size.height);
        r.size.width = IS_IPAD?w/2:w;
        r.size.height = h;
        
        for( NSInteger i = 0 ; i < [_notPurchasedSoundControllers count] ; i++ )
        {
            SoundController * controller = [_notPurchasedSoundControllers objectAtIndex:i];
            
            if( controller.view.superview == nil )
            {
                [_scrollView addSubview:controller.view];
                if( IS_IPAD )
                    r.origin.x = ((i%4)-4)*w/2;
                else
                    r.origin.x = ((i%2)-2)*w;
                controller.view.frame = r;
            }
            else
            {
                if( IS_IPAD )
                    r.origin.x = (i%4)*w/2+(i%4);
                else
                    r.origin.x = (i%2)*w+(i%2);
                controller.view.frame = r;
            }
            
            if( IS_IPAD )
            {
                if( i % 4 == 3 )
                    r.origin.y += (1+h);
            }
            else
            {
                if( i % 2 == 1 )
                    r.origin.y += (1+h);
            }
        }
        
        if( IS_IPAD )
        {
            if( ([_notPurchasedSoundControllers count]%4) != 0 )
                r.origin.y += (h+1);
        }
        else
        {
            if( ([_notPurchasedSoundControllers count]%2) != 0 )
                r.origin.y += (h+1);
        }
    }
    
    _scrollView.contentSize = CGSizeMake(r.size.width, r.origin.y);
}

- (void)showControllers
{
    CGSize s = _scrollView.bounds.size;
    CGFloat w = s.width;
    CGFloat delay = 0;
    //Purchased Sounds
    for( NSInteger i = 0 ; i < [_purchasedSoundControllers count] ; i++ )
    {
        SoundController * controller = [_purchasedSoundControllers objectAtIndex:i];
        CGRect vr = controller.view.frame;
        if( vr.origin.x < 0 )
        {
            if( vr.origin.y < s.height )
            {
                [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
                    CGRect r = controller.view.frame;
                    r.origin.x += w;
                    if( IS_IPAD )
                        r.origin.x += (i%2);
                    controller.view.frame = r;
                } completion:NULL];
                
                delay += 0.1;
            }
            else
            {
                vr.origin.x += w;
                if( IS_IPAD )
                    vr.origin.x += (i%2);
                controller.view.frame = vr;
            }
        }
    }
    
    if( [_notPurchasedSoundControllers count] > 0 )
    {
        //Unlock View
        UIView * unlockView = [UnlockController sharedInstance].view;
        CGRect vr = unlockView.frame;
        if( vr.origin.x < 0 )
        {
            if( vr.origin.y+vr.size.height < s.height )
            {
                [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
                    CGRect r = unlockView.frame;
                    r.origin.x += w;
                    unlockView.frame = r;
                } completion:NULL];
                delay += 0.1;
            }
            else
            {
                vr.origin.x += vr.size.width;
                unlockView.frame = vr;
            }
        }
        
        //Not Purchased View
        for( NSInteger i = 0 ; i < [_notPurchasedSoundControllers count] ; i++ )
        {
            SoundController * controller = [_notPurchasedSoundControllers objectAtIndex:i];
            CGRect vr = controller.view.frame;
            if( vr.origin.x < 0 )
            {
                if( vr.origin.y < s.height )
                {
                    [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
                        CGRect mr = controller.view.frame;
                        mr.origin.x += w;
                        if( IS_IPAD )
                            mr.origin.x += (i%4);
                        else
                            mr.origin.x += (i%2);
                        controller.view.frame = mr;
                    } completion:NULL];
                }
                else
                {
                    vr.origin.x += w;
                    if( IS_IPAD )
                        vr.origin.x += (i%4);
                    else
                        vr.origin.x += (i%2);
                    controller.view.frame = vr;
                }
            }
            
            if( IS_IPAD )
            {
                if( i % 4 == 3 )
                    delay += 0.1;
            }
            else
            {
                if( i % 2 == 1 )
                    delay += 0.1;
            }
        }
    }
}

#pragma mark - Intro
- (void)showIntro
{
    //hidden iAd -after help page
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IntroIsShown"]) {
        _isHelpLoaded = YES;
        _adBanner.hidden = YES;
        _adBanner.alpha = 0.0;
        bottomConstraions.constant = 0.0;
        [self updateViewConstraints];
        [self.view layoutIfNeeded];
    }
    
    //Scroll to TOP
    [_scrollView setContentOffset:CGPointZero animated:YES];
    
    self.introView = [IntroView view];
    _introView.delegate = (id<IntroViewDelegate>)self;
    [_introView show];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TipScreenEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroIsShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)introViewDidShow:(IntroView *)view
{
    SoundController * controller1 = [_purchasedSoundControllers objectAtIndex:0];
    [controller1 play:nil];
    NSInteger idx;
    if( IS_IPAD )
        idx = 3;
    else if( IS_IPHONE_5 )
        idx = 3;
    else if( IS_IPHONE_6 )
        idx = 3;
    else if( IS_IPHONE_6P )
        idx = 3;
    else
        idx = 2;
    SoundController * controller2 = [_purchasedSoundControllers objectAtIndex:idx];
    [controller2 play:nil];
    
    if( [AlarmManager sharedInstance].activeAlarm == nil )
    {
        Alarm * testAlarm = [[Alarm alloc] initTimer];
        testAlarm.uniqueId = @"TEST_ALARM";
        testAlarm.countdownSec = 180;
        testAlarm.enabled = YES;
        [[AlarmManager sharedInstance] addAlarm:testAlarm];
    }
}

- (void)introViewDidClose:(IntroView *)view
{
    //add iAd
    if (_isHelpLoaded) {
        NSLog(@"help page....");
        _adBanner.hidden = NO;
        _adBanner.alpha = 1.0;
        bottomConstraions.constant = 50.0;
        [self updateViewConstraints];
        [self.view layoutIfNeeded];
    }else {
        NSLog(@"first load page....");
        [self addIADBanner];
    }
    
    
    
    //sound controller
    SoundController * controller1 = [_purchasedSoundControllers objectAtIndex:0];
    [controller1 play:nil];
    NSInteger idx;
    if( IS_IPAD )
        idx = 3;
    else if( IS_IPHONE_5 )
        idx = 3;
    else if( IS_IPHONE_6 )
        idx = 3;
    else if( IS_IPHONE_6P )
        idx = 3;
    else
        idx = 2;
    SoundController * controller2 = [_purchasedSoundControllers objectAtIndex:idx];
    [controller2 play:nil];
    
    if( [[AlarmManager sharedInstance] removeAlarmWithUniqueId:@"TEST_ALARM"] )
        [_alarmTimeView setHidden:YES];
}

- (void)onIntroScreen:(NSNotification *)n
{
    //Stop all playing sounds
    NSInteger nCnt = 0;
    for( SoundController * controller in _purchasedSoundControllers )
    {
        if( controller.isPlaying )
        {
            [controller stop];
            
            nCnt++;
        }
    }

    if( nCnt > 0 )
        [self performSelector:@selector(showIntro) withObject:nil afterDelay:1.5];
    else
        [self showIntro];
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

#pragma mark - View Transition
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark - Play Favorite
- (void)onPlayFavorite:(NSNotification *)notification
{
    Favorite * favorite = [notification.userInfo objectForKey:kNotificatonFavoritekey];
    [self playFavorite:favorite];
}

- (void)playFavorite:(Favorite *)favorite
{
    if( favorite != nil )
    {
        [self stopAll:nil];
        
        for( NSString * sId in favorite.soundIds )
        {
            SoundController * sc = nil;
            for( SoundController * c in _purchasedSoundControllers )
            {
                if( [sId isEqualToString:c.sound.uniqueId] )
                {
                    sc = c;
                    break;
                }
            }
            if( sc != nil )
            {
                if( !sc.isPlaying )
                    [sc play:nil];
            }
        }
    }
}

#pragma mark - Alarm
- (void)alarmActive:(NSNotification *)n
{
    if( n.userInfo == nil )
        _alarmTimeView.hidden = YES;
    else
    {
        Alarm * alarm = [n.userInfo objectForKey:@"alarm"];
        if( alarm != nil )
        {
            _alarmTimeView.hidden = NO;
            _alarmTimeLabel.text = [alarm stringForTime];
            _alarmTimeImageView.image = (alarm.type==0)?[UIImage imageNamed:@"w_alarm"]:[UIImage imageNamed:@"w_timer"];
        }
    }
}

- (void)alarmFire:(NSNotification *)n
{
    NSLog(@"Dashboard: Alarm Fire");
    Alarm * alarm = [n.userInfo objectForKey:@"alarm"];
    if( alarm.type == 0 )
    {
        //Alarm(Fire Alarm)
        if( alarm.exitApp )
        {
            //Terminate App
        }
        else
        {
            if( alarm.soundId == nil )
            {
                //Play "current mix selection"
            }
            else
            {
                //Play favorite sounds
                Favorite * favorite = [Favorite favoriteForUniqueId:alarm.soundId];
                [self playFavorite:favorite];
            }
        }
    }
    else// if( alarm.type == 1 )
    {
        //Timer(Stop Alarm)
        [self stopAll:nil];
        
        if( [alarm.uniqueId isEqualToString:@"TEST_ALARM"] && (_introView!=nil) )
            [_introView removeFromSuperview];
    }
}

#pragma mark - User Rated
- (void)onUserRated:(NSNotification *)n
{
//    NSArray * ary = [[MSoundManager sharedInstance] soundForRate];
//    MSound *s = ary.firstObject;
//    s.isUsable = YES;
//    s.type = SOUND_FREE;
//    SoundController * controller = [[SoundController alloc] initWithSound:s];
//    [controller setDelegate:self];
//    [_purchasedSoundControllers addObject:controller];
//    [[MSoundManager sharedInstance] saveSounds];
//    _isNeedReload = YES;
    
    MSound * theSound = [self.rateSoundController sound];
    theSound.type = SOUND_FREE;
    SoundController * newController = [[SoundController alloc] initWithSound:theSound];
    [newController setDelegate:self];
    
    [self.rateSoundController purchased];
    
    MSound * nextSound = [self.rateSoundController sound];
    if( nextSound == nil )
    {
        [self.rateSoundController.view removeFromSuperview];
        [self.notPurchasedSoundControllers removeObject:self.rateSoundController];
    }
    else
    {
        [self.rateSoundController startAnimate];
    }
    
    [_purchasedSoundControllers addObject:newController];
    
    CGSize s = _scrollView.frame.size;
    CGFloat yOffset = (SOUND_VIEW_HEIGHT+1)*([self.purchasedSoundControllers count]-1);
    if( s.height < yOffset)
    {
        yOffset -= s.height/2;
        [_scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    }
    [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
    [[MSoundManager sharedInstance] saveSounds];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"rated" forKey:@"RateSound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SoundControllerDelegate
- (void)SoundControllerDidStartPlaying:(SoundController *)controller
{
    [MSoundManager activeAudioSession:YES];
    [_pause_resumeButton setSelected:NO];
}

- (void)SoundControllerDidStopPlaying:(SoundController *)controller
{
    [MSoundManager activeAudioSession:NO];
}

- (void)SoundControllerUnlockAll:(SoundController *)controller{
    SubscribeViewController * subscribeViewController = [[SubscribeViewController alloc] initWithNibName:@"SubscribeView" bundle:nil];
    [self presentViewController:subscribeViewController animated:YES completion:NULL];
}

- (void)SoundControllerRate:(SoundController *)controller{

    RateViewController * rateViewController = [[RateViewController alloc] initWithNibName:@"RateView" bundle:nil];
    [self presentViewController:rateViewController animated:YES completion:NULL];
    
    /*
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Notice"
                                  message:@"Please rate us to unlock this extra sound for free! Every bit helps support us and bring you more free updates."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes, please"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    MSound * theSound = [self.rateSoundController sound];
                                    theSound.type = SOUND_FREE;
                                    SoundController * newController = [[SoundController alloc] initWithSound:theSound];
                                    [newController setDelegate:self];
                                    
                                    [self.rateSoundController purchased];
                                    
                                    MSound * nextSound = [self.rateSoundController sound];
                                    if( nextSound == nil )
                                    {
                                        [self.rateSoundController.view removeFromSuperview];
                                        [self.notPurchasedSoundControllers removeObject:self.rateSoundController];
                                    }
                                    else
                                    {
                                        [self.rateSoundController startAnimate];
                                    }
                                    
                                    [_purchasedSoundControllers addObject:newController];
                                    
                                    CGSize s = _scrollView.frame.size;
                                    CGFloat yOffset = (SOUND_VIEW_HEIGHT+1)*([self.purchasedSoundControllers count]-1);
                                    if( s.height < yOffset)
                                    {
                                        yOffset -= s.height/2;
                                        [_scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
                                    }
                                    [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
                                    [[MSoundManager sharedInstance] saveSounds];
                                    
                                    [[NSUserDefaults standardUserDefaults] setObject:@"rated" forKey:@"RateSound"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No, thanks"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handel no, thanks button
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil]; */
}

- (void)SoundControllerPlayingVideoAd:(SoundController *)controller
{
    NSDate * oldDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdWatchedDate"];
    if( oldDate != nil && [[NSDate date] timeIntervalSince1970] - [oldDate timeIntervalSince1970] < 24*3600 )
        return;
    
    [[VungleSDK sharedSDK] setDelegate:self];
    
    //We might have cached an ad before we reached this ViewController, or might have one cached from a previous launch
    if( [[VungleSDK sharedSDK] isAdPlayable] )
    {
        VungleSDK* sdk = [VungleSDK sharedSDK];
        NSError *error = nil;
        [sdk playAd:self error:&error];
        if( error != nil )
            NSLog(@"Error encountered playing ad: %@", error);
        else
        {
            controller.isInPurchasing = YES;
            
            [controller stopAnimate];
        }
    }
    
    /*// showAdWithOptions: Dict to set custom ad options
    NSDictionary* options = @{VunglePlayAdOptionKeyOrientations: @(UIInterfaceOrientationMaskLandscape),
                              VunglePlayAdOptionKeyUser: @"user",
                              VunglePlayAdOptionKeyPlacement: @"StoreFront",
                              // Use this to keep track of metrics about your users
                              VunglePlayAdOptionKeyExtraInfoDictionary: @{VunglePlayAdOptionKeyExtra1: @"21",
                                                                          VunglePlayAdOptionKeyExtra2: @"Female"}};
    
    // Pass in dict of options, play ad
    NSError *error;
    [[VungleSDK sharedSDK] playAd:self withOptions:options error:&error];
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
    }
     */
    
    /*// showIncentivizedAd. Dict to set custom ad options
    NSDictionary* options = @{VunglePlayAdOptionKeyIncentivized: @YES,
                              VunglePlayAdOptionKeyIncentivizedAlertBodyText : @"If the video isn't completed you won't get your reward! Are you sure you want to close early?",
                              VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText : @"Close",
                              VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText : @"Keep Watching",
                              VunglePlayAdOptionKeyIncentivizedAlertTitleText : @"Careful!"};
    
    // Pass in dict of options, play ad
    NSError *error;
    [[VungleSDK sharedSDK] playAd:self withOptions:options error:&error];
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
    }
     */
}

#pragma mark - VungleSDK Delegate
- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    [self.videoWatchSoundController enable:isAdPlayable];
    
    if( isAdPlayable )
        NSLog(@"An ad is available for playback");
    else
        NSLog(@"No ads currently available for playback");
}

- (void)vungleSDKwillShowAd
{
    NSLog(@"An ad is about to be played!");
    //Use this delegate method to pause animations, sound, etc.
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    if( willPresentProductSheet )
    {
        //In this case we don't want to resume animations and sound, the user hasn't returned to the app yet
        NSLog(@"The ad presented was tapped and the user is now being shown the App Product Sheet");
        NSLog(@"ViewInfo Dictionary:");
        for( NSString * key in [viewInfo allKeys] )
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
    }
    else
    {
        //In this case the user has declined to download the advertised application and is now returning fully to the main app
        //Animations / Sound / Gameplay can be resumed now
        NSLog(@"The ad presented was not tapped - the user has returned to the app");
        NSLog(@"ViewInfo Dictionary:");
        for( NSString * key in [viewInfo allKeys] )
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
    }
    
    if( self.videoWatchSoundController.isInPurchasing )
    {
        MSound * theSound = [self.videoWatchSoundController sound];
        theSound.type = SOUND_FREE;
        SoundController * newController = [[SoundController alloc] initWithSound:theSound];
        [newController setDelegate:self];

        [self.videoWatchSoundController purchased];

        MSound * nextSound = [self.videoWatchSoundController sound];
        if( nextSound == nil )
        {
            [self.videoWatchSoundController.view removeFromSuperview];
            [self.notPurchasedSoundControllers removeObject:self.videoWatchSoundController];
        }
        else
        {
            [self.videoWatchSoundController startAnimate];
        }
        
        [_purchasedSoundControllers addObject:newController];
        
        CGSize s = _scrollView.frame.size;
        CGFloat yOffset = (SOUND_VIEW_HEIGHT+1)*([self.purchasedSoundControllers count]-1);
        if( s.height < yOffset)
        {
            yOffset -= s.height/2;
            [_scrollView setContentOffset:CGPointMake(0, yOffset) animated:YES];
        }
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
        [[MSoundManager sharedInstance] saveSounds];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"AdWatchedDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    NSLog(@"The user has downloaded an advertised application and is now returning to the main app");
    //This method can be used to resume animations, sound, etc. if a user was presented a product sheet earlier
}

#pragma mark - Unlock Additional Sounds
- (void)didUnlockAll:(NSNotification *)n
{
    if( [[UnlockController sharedInstance] isUnlocked] )
    {
        //reset constraints
        bottomConstraions.constant = 0.0;
        
        //Not Purchased
        for( SoundController * controller in _notPurchasedSoundControllers )
        {
            if( controller == _videoWatchSoundController )
                continue;
            
            [controller purchased];
            [controller.view removeFromSuperview];
            
            SoundController * newController = [[SoundController alloc] initWithSound:controller.sound];
            [newController setDelegate:self];
            [_purchasedSoundControllers addObject:newController];
        }
        
        [_notPurchasedSoundControllers removeAllObjects];
        [[UnlockController sharedInstance].view removeFromSuperview];
        
        //Video Ad
        if( self.videoWatchSoundController != nil )
        {
            [_videoWatchSoundController stopAnimate];
            if( _videoWatchSoundController.sounds != nil )
            {
                NSArray * sounds = _videoWatchSoundController.sounds;
                [sounds enumerateObjectsUsingBlock:^(MSound * s, NSUInteger idx, BOOL * _Nonnull stop) {
                    s.isUsable = YES;
                    SoundController * newController = [[SoundController alloc] initWithSound:s];
                    [newController setDelegate:self];
                    [_purchasedSoundControllers addObject:newController];
                }];
                [_videoWatchSoundController.view removeFromSuperview];
            }
            self.videoWatchSoundController = nil;
        }
        
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.5];
        [[MSoundManager sharedInstance] saveSounds];
    }
}

#pragma mark - Button Events
- (IBAction)pause_resume:(id)sender
{
    if( [_pause_resumeButton isSelected] )
    {
        //Perform "resume"
        [_pause_resumeButton setSelected:NO];
        for( SoundController * controller in _purchasedSoundControllers )
        {
            [controller resume];
        }
    }
    else
    {
        //Perform "pause"
        [_pause_resumeButton setSelected:YES];
        for( SoundController * controller in _purchasedSoundControllers )
        {
            [controller pause];
        }
    }
}

- (IBAction)stopAll:(id)sender
{
    for( SoundController * controller in _purchasedSoundControllers )
    {
        [controller stop];
    }
}

- (IBAction)controlVolume:(id)sender
{
    if( _volumeButton.selected )
    {
        [self hideVolumeControlViewAnimated:YES];
        [_volumeButton setSelected:NO];
    }
    else
    {
        [self showVolumeControlViewAnimated:YES];
        [_volumeButton setSelected:YES];
    }
}

- (IBAction)timerAlarm:(id)sender
{
    //Implemented in Storyboard
}

- (IBAction)clcok:(id)sender
{
    //Implemented in Stroyboard
}

#pragma mark - Volume Control

- (void)initVolumeControlView
{
    MPVolumeView * volumeView = [[MPVolumeView alloc] initWithFrame:_volumeControlContainerView.bounds];
    [volumeView setTintColor:[UIColor colorWithRed:0.745f green:0.839f blue:0.184 alpha:1.0f]];
    [volumeView setVolumeThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [volumeView setVolumeThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateHighlighted];
    [_volumeControlContainerView addSubview:volumeView];
    
    [self hideVolumeControlViewAnimated:NO];
}

- (void)showVolumeControlViewAnimated:(BOOL)a
{
    if( a )
    {
        [UIView animateWithDuration:0.3 animations:^{
            _volumeControlViewConstraint.constant = 0;
            [_volumeControlView layoutIfNeeded];
        }];
    }
    else
        _volumeControlViewConstraint.constant = 0;
}

- (void)hideVolumeControlViewAnimated:(BOOL)a
{
    if( a )
    {
        [UIView animateWithDuration:0.3 animations:^{
            _volumeControlViewConstraint.constant = -60;
            [_volumeControlView layoutIfNeeded];
        }];
    }
    else
        _volumeControlViewConstraint.constant = -60;
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
}

#pragma mark ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    banner.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    [UIView animateWithDuration:0.1 animations:^{
        _adBanner.alpha = 1.0;
        bottomConstraions.constant = 50.0;
        [self updateViewConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView animateWithDuration:0.5 animations:^{ _adBanner.alpha = 0.0;}];
}

@end
