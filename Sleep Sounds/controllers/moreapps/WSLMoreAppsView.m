//
//  WSLMoreAppsView.m
//  C25K
//
//  Created by Aleksey Mazurenko on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSLMoreAppsView.h"
#import "AppDefine.h"
#import "MoreApps.h"

#import "UIView+I7ShakeAnimation.h"
#import <CommonCrypto/CommonDigest.h>

#import "JSONRPCClient+Invoke.h"
#import "JSONRPCClient+Notification.h"
#import "JSONRPCClient+Multicall.h"
#define kGetResponseApiKey @"39a72bb775e621eca16c54c7a132a61e"
#define kGetResponseServer @"http://api2.getresponse.com"
#define kGetResponseCampaign @"nLjW"


#define kRegistered             @"pinkEmail"


@implementation WSLMoreAppsView
@synthesize labelTips;
@synthesize labelQuotes;
@synthesize tfEmail;
@synthesize btnRegister;
@synthesize myScrollView;
@synthesize pageControl;

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications {
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
	
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	int yOffset = kbSize.height;
	
	
	[UIView animateWithDuration:duration animations:^{
		CGRect f = self.frame;
		f.origin.y -= yOffset;
		self.frame = f;
	}];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
	
	NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	int yOffset = kbSize.height;
	
	[UIView animateWithDuration:duration animations:^{
		CGRect f = self.frame;
		f.origin.y += yOffset;
		self.frame = f;
	}];
}

#pragma mark - Init/release
+ (WSLMoreAppsView *)instance
{
    WSLMoreAppsView * view = nil;
	id<UIApplicationDelegate> a = [[UIApplication sharedApplication] delegate];
	if( [a respondsToSelector:@selector(window)] )
	{
		view = [[[NSBundle mainBundle] loadNibNamed:@"WSLMoreAppsView" owner:a options:nil] objectAtIndex:0];
		view.hidden = YES;
	}
    
    return view;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if( self != nil )
	{
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setAutoresizesSubviews:YES];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
		[self registerForKeyboardNotifications];
	}
	
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)awakeFromNib
{
    hud = [[ATMHud alloc] initWithDelegate:self];
    [self addSubview:hud.view];
}

- (void)displayApps
{
    for (UIView *v in myScrollView.subviews)
    {
        if( [v isKindOfClass:[UIButton class]] )
            [v removeFromSuperview];
    }
    
    int howmany;
    float howmanyf;
    
    if( IS_IPAD )
    {
        howmany=5;
        howmanyf=5.0;
    }
    else
    {
        howmany=3;
        howmanyf=3.0;
    }
    
    NSArray * apps = [[MoreApps sharedInstance] availableMoreApps];
    
    int  hOffset = 0, col = 0, vMargin = 0, hMargin = 0, index = 0;
    for( ZenlabsApp * app in apps )
    {
        //
        // create app button
        //
        UIView * buttonTextView = [[[NSBundle mainBundle] loadNibNamed:@"WSLMoreAppsViewAppBtn" owner:self options:nil] objectAtIndex:0];
        //UIButton * b = [[[NSBundle mainBundle] loadNibNamed:@"WSLMoreAppsViewAppBtn" owner:self options:nil] objectAtIndex:0];
        
        UIButton * b = (UIButton *)[buttonTextView viewWithTag:1];
        UILabel * t = (UILabel *)[buttonTextView viewWithTag:2];
        
        if( !vMargin )
        {
            vMargin = (myScrollView.frame.size.height - buttonTextView.frame.size.height) / 2;
            hMargin = (myScrollView.frame.size.width - howmany * buttonTextView.frame.size.width) / howmany;
            
            hOffset = hMargin;
        }
        
        [b setTag:index];
        [b setImage:[UIImage imageWithContentsOfFile:[app pathForAppIcon]] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(appBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [t setText:app.appName];
        [buttonTextView setFrame:CGRectMake(hOffset, vMargin, buttonTextView.frame.size.width, buttonTextView.frame.size.height)];
        [myScrollView addSubview:buttonTextView];
        
        col++;
        index++;
        hOffset += hMargin + buttonTextView.frame.size.width;
    }
    
    [myScrollView setContentSize:CGSizeMake(hOffset, myScrollView.frame.size.height)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [myScrollView addGestureRecognizer:singleTap];
    pageControl.numberOfPages = ceil(index / howmanyf);
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if( [defaults valueForKey:kRegistered] )
    {
        for( UIView *v in _contentView.subviews)
            [v removeFromSuperview];
        
        [_contentView addSubview:_registeredView];
        
        [featuredBtn setHidden:NO];
        [featuredLbl setHidden:NO];
        [featuredAppLbl setHidden:NO];
        [appTitleLbl setHidden:NO];
        [btnRegister setHidden:YES];
        [tfEmail setHidden:YES];
    }
    else
    {
        for (UIView *v in _contentView.subviews)
            [v removeFromSuperview];
        
        [_contentView addSubview:_standardView];
    }
}

- (void)show
{
	//
	// load random messages
	//
    TipInfo * tip = [[MoreApps sharedInstance] tipInfo];
    
	labelTips.text = [tip randomTip];

    //Quotes
    NSString * str= [NSString stringWithFormat:@"\"  %@  \"", [tip randomQuote]];
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:str];
    if( IS_IPAD )
    {
        [atr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Light" size:65] range:NSMakeRange(0, 1)];
        [atr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Light" size:65] range:NSMakeRange(str.length-1, 1)];
    }
    else
    {
        [atr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Light" size:45] range:NSMakeRange(0, 1)];
        [atr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Light" size:45] range:NSMakeRange(str.length-1, 1)];
    }
    [atr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:117.0/255.0 green:166.0/255.0 blue:8.0/255.0 alpha:1] range:NSMakeRange(0, 1)];
    [atr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:117.0/255.0 green:166.0/255.0 blue:8.0/255.0 alpha:1] range:NSMakeRange(str.length-1, 1)];
    labelQuotes.attributedText=atr;
    
    NSArray * featuredApps = [[MoreApps sharedInstance] availableFeaturedAppps];
    if( [featuredApps count] > 0 )
    {
        FeaturedApp * app = [featuredApps objectAtIndex:0];

        featuredLbl.text = app.appDescription;
        appTitleLbl.text = app.appName;
        
        [featuredBtn setImage:[UIImage imageWithContentsOfFile:[app pathForAppIcon]] forState:UIControlStateNormal];
    }
    else
    {
        featuredLbl.text = @"";
        appTitleLbl.text = @"";
    }
    
	[self displayApps];
	
	//
	// display popup
	//
	id<UIApplicationDelegate> a = [[UIApplication sharedApplication] delegate];
	if( [a respondsToSelector:@selector(window)] )
	{
		UIWindow *window = [a window];
		
		self.alpha = 0;
		self.hidden = NO;
	        
		[window addSubview:self];
		
		[UIView animateWithDuration:0.3 animations:^{
			self.alpha = 1;
		}];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        _isOpened = YES;
	}
}

- (void)hide
{
	if( !self.superview )
		return;
	
	[UIView animateWithDuration:0.3 animations:^{
		self.alpha = 0;
	} 
	completion:^(BOOL finished){
		self.hidden = YES;		
		[self removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        _isOpened = NO;
        
        
        if( (_delegate!=nil) && [_delegate respondsToSelector:@selector(WSLMoreAppsViewClosed:)] )
            [_delegate WSLMoreAppsViewClosed:self];
	}];
}

- (BOOL)isValidEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}


#pragma mark - Register

- (void)sendEMAIL
{
    NSString* email = tfEmail.text;
    
    // RPC Test
    JSONRPCClient *rpc = [[JSONRPCClient alloc] initWithServiceEndpoint:kGetResponseServer];
    NSMutableArray *params = [[NSMutableArray alloc] initWithObjects:kGetResponseApiKey, nil];
    
    //    [rpc invoke:@"get_campaigns" params:params onCompleted:^(RPCResponse *response) {
    //
    //        NSLog(@"get_campaigns");
    //        NSLog(@"Respone: %@", response);
    //        NSLog(@"Error: %@", response.error);
    //        NSLog(@"Result: %@", response.result);
    //
    //    }];
    
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:kGetResponseCampaign forKey:@"campaign"];
    [tmp setValue:email forKey:@"email"];
    [tmp setValue:[NSNumber numberWithInt:0] forKey:@"cycle_day"];
    [params addObject:tmp];

    NSLog(@"params:%@",params);
    [rpc invoke:@"add_contact" params:params onCompleted:^(RPCResponse *response)
    {
        NSLog(@"add_contact");
        NSLog(@"Respone: %@", response);
        NSLog(@"Error: %@", response.error);
        NSLog(@"Result: %@", response.result);
    }];
    
    hud.blockTouches = NO;
    hud.allowSuperviewInteraction = NO;
    [hud setCaption:@"Registered!"];
    [hud setImage:[UIImage imageNamed:@"19-check.png"]];
    [hud setActivity:NO];
    [hud update];
    [hud hideAfter:2];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"1" forKey:kRegistered];
    [defaults synchronize];
    NSLog(@"email1:%@",[defaults valueForKey:kRegistered]);
    [self displayApps];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - IBActions

- (IBAction)btnRegisterClicked:(id)sender
{
    [tfEmail resignFirstResponder];
    if( ![tfEmail.text length] || ![self isValidEmail:tfEmail.text] )
    {
        [tfEmail shakeXWithOffset:30.0 breakFactor:0.7 duration:0.7 maxShakes:5];
        return;
    }
    
    hud.blockTouches = YES;
    hud.allowSuperviewInteraction = NO;
    
    [hud setCaption:@"Registering You..."];
    [hud setActivity:YES];
    [hud show];
    
    [self sendEMAIL];
}

- (IBAction)btnCloseClicked:(id)sender
{
	[self hide];
}

- (IBAction)linkToApp:(id)sender
{
    NSArray * apps = [[MoreApps sharedInstance] availableFeaturedAppps];
    if( [apps count] > 0 )
    {
        FeaturedApp * app = [apps objectAtIndex:0];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.appURL]];
    }
}

- (IBAction)appBtnClicked:(UIButton *)sender
{
	NSInteger index = sender.tag;
	NSArray *allApps = [[MoreApps sharedInstance] availableMoreApps];
	
	if( index < 0 || index >= [allApps count] )
		return;

    ZenlabsApp * app = [allApps objectAtIndex:index];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.appURL]];
}

#pragma mark- Touch delegate
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:myScrollView];
    
    
    UIButton* but=[[UIButton alloc] init];
    but.tag=(int)touchPoint.x/90;
    if( IS_IPAD )
        but.tag=(int)touchPoint.x/(myScrollView.frame.size.width/5);
    
    [self appBtnClicked:but];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
	
	pageControl.currentPage = page;
}

@end

@implementation NSData (MD5)
- (NSString *)MD5 {
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	
	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
	
	// Convert unsigned char buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
		[output appendFormat:@"%02x",md5Buffer[i]];
	
	return output;
}
@end

@implementation NSDictionary (Data)
+ (NSDictionary *)dictionaryWithData:(NSData *)data
{
    id obj = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable
                                                        format:NULL
                                              errorDescription:nil];
    
    return obj;
}

- (NSData *)dataRepresentation
{
	return [NSPropertyListSerialization dataFromPropertyList:self format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
}

@end

