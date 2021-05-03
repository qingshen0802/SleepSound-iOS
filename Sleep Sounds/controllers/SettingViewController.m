//
//  SettingViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 26/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "SettingViewController.h"
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>
#import "AppDefine.h"
#import "ForumViewController.h"
#import "MoreAppsViewController.h"
#import "MNavigationViewController.h"
#import "RateViewController.h"
#import "SubscribeViewController.h"
#import <Social/Social.h>
#import "SWRevealViewController.h"
#import "UnlockController.h"
#import "SettingTableViewCell.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *settingTableView;

@end

@implementation SettingViewController{
    BOOL _isShareViewShown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchasedProduct:)
                                                 name:kNotificationDidPurchaseProduct
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDidPurchaseProduct object:nil];
}

- (void)purchasedProduct:(NSNotification *)n
{
    [self.settingTableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11; //11
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"reuse_facebook";
            break;
            
        case 1:
            CellIdentifier = @"reuse_twitter";
            break;
            
        case 2:
            CellIdentifier = @"reuse_instagram";
            break;

        case 3:
            CellIdentifier = @"reuse_tips"; //reuse_rateus
            break;
            
        case 4:
            CellIdentifier = @"reuse_feedback";
            break;
            
        case 5:
            CellIdentifier = @"reuse_share";
            break;
            
        case 6:
            CellIdentifier = @"reuse_help";
            break;
            
        case 7:
            CellIdentifier = @"reuse_unlock";
            break;
            
        case 8:
            CellIdentifier = @"reuse_restore";
            break;
            
        case 9:
            CellIdentifier = @"reuse_forums";
            break;
            
        case 10:
            CellIdentifier = @"reuse_moreapps";
            break;
    }
    
    
    
    if (indexPath.row == 3) {
        SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
        cell.switchBtn.on = [[NSUserDefaults standardUserDefaults] boolForKey:TipScreenEnabled];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
        
        if( indexPath.row == 7 ) //7
        {
            UnlockCellView * unlockCell = (UnlockCellView *)cell;
            if( [[UnlockController sharedInstance] isUnlocked] )
                unlockCell.secondLabel.text = @"Unlocked";
            else
                unlockCell.secondLabel.text = @"";
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch( indexPath.row )
    {
        case 0:
            //Facebook
            [self onLikeUsOnFacebook];
            break;
            
        case 1:
            //Twitter
            [self onFollowUsOnTwitter];
            break;
            
        case 2:
            //Instagram
            [self onFollowUsOnInstagram];
            break;
            
        case 3:
            //Rate Us
//            [self onRate];
            //tips screen
            
            break;
            
        case 4:
            //Feedback
            [self onFeedback];
            break;
        case 5:
            //Share
            if( _isShareViewShown )
            {
                ShareCellView * cell = (ShareCellView *)[tableView cellForRowAtIndexPath:indexPath];
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     cell.shareViewConstraint.constant = -70;
                                     [cell.shareView layoutIfNeeded];
                                 } completion:^(BOOL finished) {_isShareViewShown = NO;}];
            }
            else
            {
                ShareCellView * cell = (ShareCellView *)[tableView cellForRowAtIndexPath:indexPath];
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     cell.shareViewConstraint.constant = 60;
                                     [cell.shareView layoutIfNeeded];
                                 } completion:^(BOOL finished) {_isShareViewShown = YES;}];
            }
            break;
        case 6:
            //Help
            [self onHelp];
            break;
            
        case 7:
            //Subscribe
            [self onUnlock];
            break;
            
        case 8:
            //Restore
            [self onRestore];
            break;
            
        case 9:
            //Forum
            [self onForum];
            break;
            
        case 10:
            //More Apps
            [self onMoreApps];
            break;
    }
}

#pragma mark - Functions
- (IBAction)changeSwitchBtn:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:TipScreenEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onLikeUsOnFacebook
{
    UIApplication *a = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", kFacebookId]];
    if( ![a canOpenURL:url] )
        url = [NSURL URLWithString:kFacebookLink];
    [a openURL:url];
}

- (void)onFollowUsOnTwitter
{
    UIApplication *a = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", kTwitterId]];
    if( ![a canOpenURL:url] )
        url = [NSURL URLWithString:kTwitterLink];
    [a openURL:url];
}

- (void)onFollowUsOnInstagram
{
    UIApplication *a = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", kInstagramId]];
    if (![a canOpenURL:url])
        url = [NSURL URLWithString:kInstagramLink];
    [a openURL:url];
}

- (void)onRate
{
    RateViewController * rateViewController = [[RateViewController alloc] initWithNibName:@"RateView" bundle:nil];
    [self presentViewController:rateViewController animated:YES completion:NULL];
}

- (void)onFeedback
{
    if( [MFMailComposeViewController canSendMail] )
    {
        struct utsname u;
        uname(&u);
        char *type = u.machine;
        NSString *strType = [NSString stringWithFormat:@"%s", type];
        NSString *strBody = [NSString stringWithFormat:@"\n\n\nAppName: %@\nApp Version: %@\nDevice Model: %@\nOS Version: %@", APP_NAME, [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]], strType, [[UIDevice currentDevice] systemVersion]];
        
        MFMailComposeViewController * mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        [mailController setSubject:@"App Feedback - Sleep Sounds"];
        [mailController setMessageBody:strBody isHTML:NO];
        [mailController setToRecipients:@[@"contactus@zenlabsfitness.com"]];
        [self presentViewController:mailController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device can't send email.");
    }
}

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"Mail Error: %@", error);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onHelp
{
    SWRevealViewController * viewController = self.revealViewController;
    [viewController revealToggle:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIntroScreenNotification object:nil];
}

- (void)onUnlock
{
    if( ![[UnlockController sharedInstance] isUnlocked] )
    {
        SWRevealViewController * viewController = self.revealViewController;
        [viewController revealToggle:nil];
        
        SubscribeViewController * subscribeViewController = [[SubscribeViewController alloc] initWithNibName:@"SubscribeView" bundle:nil];
        [self presentViewController:subscribeViewController animated:YES completion:NULL];
    }
}

- (void)onRestore
{
    [[UnlockController sharedInstance] restore];
}

- (void)onForum
{
    ForumViewController * forumViewController = [[ForumViewController alloc] init];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:forumViewController];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)onMoreApps
{
    if( [MoreAppsViewController availableToOpen] )
    {
        MoreAppsViewController * moreAppViewController = [[MoreAppsViewController alloc] init];
        MNavigationViewController * navController = [[MNavigationViewController alloc] initWithRootViewController:moreAppViewController];
        [self presentViewController:navController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                         message:@"Information is currently loading, please check back in a couple minutes. Thanks!"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark - Share
- (IBAction)onShareViewMail:(id)sender
{
    if( [MFMailComposeViewController canSendMail] )
    {
        NSString *strBody = [NSString stringWithFormat:@"Hey! check out the newest Sleep Sounds app.<BR><BR><A href=itms-apps://itunes.apple.com/app/id1043666505>%@</A><BR><BR>You can also check out their awesome community here:<BR>http://www.facebook.com/zenlabsfitness<BR>http://twitter.com/zenlabsfitness<BR>http://instagram.com/zenlabsfitness<BR>http://forums.zenlabsfitness.com", APP_NAME];
        
        MFMailComposeViewController * mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        [mailController setSubject:@"Check out the new Sleep Sounds app!"];
        [mailController setMessageBody:strBody isHTML:YES];
        
        [self presentViewController:mailController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device can't send email.");
    }
}

- (IBAction)onShareViewFacebook:(id)sender
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"Check out the newest Sleep Sounds app from @zenlabsfitness! %@", AppURL];
    [self presentViewController:controller animated:YES completion:Nil];
}

- (IBAction)onShareViewTwitter:(id)sender
{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:[NSString stringWithFormat:@"Check out the newest Sleep Sounds app from @zenlabsfitness! %@", AppURL]];
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

@end

@implementation ShareCellView
@end

@implementation UnlockCellView
@end