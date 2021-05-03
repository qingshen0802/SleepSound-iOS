//
//  SplashViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 22/2/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDefine.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewAnimation];
}

-(void)viewAnimation {
    NSURL *url;
    
    if (IS_IPAD) {
        url = [[NSBundle mainBundle] URLForResource:@"Openeripad" withExtension:@"mp4"];
    }
    else{
        
        if ([UIScreen mainScreen].bounds.size.height==480) {
            url = [[NSBundle mainBundle] URLForResource:@"Opener480" withExtension:@"mp4"];
        }
        else{
            
            url = [[NSBundle mainBundle] URLForResource:@"Opener" withExtension:@"mp4"];
        }
        
    }
    
    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    _moviePlayer.backgroundView.backgroundColor=[UIColor clearColor];
    _moviePlayer.view.backgroundColor=[UIColor clearColor];
    
    for(UIView *aSubView in _moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    _moviePlayer.shouldAutoplay = NO;
    _moviePlayer.view.frame=self.view.frame;
    
    [_moviePlayer prepareToPlay];
   
    
    [self.view addSubview:_moviePlayer.view];
}

-(void)loadStateChanged:(NSNotification *)notification
{
    
    
    if(_moviePlayer.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK))
    {
        [_moviePlayer play];
    }
    
    
    
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    [player.view removeFromSuperview];
   
//    [self performSegueWithIdentifier:@"goRealVCSegue" sender:self];
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    SWRevealViewController * revealController = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    if( [revealController isKindOfClass:[SWRevealViewController class]] )
        revealController.rightViewRevealWidth = self.view.bounds.size.width - ([Utils isIPHONE]?50:60);
    del.window.rootViewController = revealController;
}

@end
