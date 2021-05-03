//
//  RateViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 5/2/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import "RateViewController.h"
#import "MSoundManager.h"
#import "ImageCache.h"

@interface RateViewController ()
@property (strong, nonatomic) IBOutlet UILabel *soundLabel;
@property (strong, nonatomic) IBOutlet UIImageView *soundImage;

@end

@implementation RateViewController

+ (BOOL)userRated
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"userRated"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *ary = [[MSoundManager sharedInstance] soundForRate];
    MSound * s = ary.firstObject;
    [self.soundLabel setText:s.name];
    [self.soundImage setImage:[[ImageCache sharedInstance] imageNamed:s.background]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Event
- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onYesPlease:(id)sender
{
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1043666505"];
    if( [[UIApplication sharedApplication] canOpenURL:url] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userRated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_UserRated object:nil];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
