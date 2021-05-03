//
//  UnlockController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 14/12/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "UnlockController.h"

@interface UnlockController () <StoreManagerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buyButton;

@end

@implementation UnlockController

+ (UnlockController *)sharedInstance
{
    static UnlockController * singletonUnlockController = nil;
    if( singletonUnlockController == nil )
        singletonUnlockController = [[UnlockController alloc] initWithNibName:@"UnlockView" bundle:nil];
    return singletonUnlockController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self != nil )
    {
        self.unlockForever = [[MProduct alloc] initWithProductId:@"com.zenlabs.sleepsounds.unlockadditionalsounds"];
        self.unlock3Months = [[MProduct alloc] initWithProductId:@"com.zenlabs.sleepsounds.unlock3months"];
        self.unlock1Month  = [[MProduct alloc] initWithProductId:@"com.zenlabs.sleepsounds.unlock1month"];

        self.unlock3Months.isNeedValidatingReceipt = YES;
        self.unlock1Month.isNeedValidatingReceipt = YES;
        self.isBusy = NO;
        
        [[StoreManager sharedInstance] setDelegate:self];
        [[StoreManager sharedInstance] registerProducts:@[_unlockForever, _unlock3Months, _unlock1Month]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBuy:(id)sender
{
    [self buyUnlock1Month];
}

#pragma mark - Public
- (BOOL)isUnlocked
{
    if( [_unlockForever isUsable] )
        return YES;
    return ([_unlock1Month isUsable] || [_unlock3Months isUsable]);
}

- (void)buyUnlockForever
{
    if( self.isBusy )
        return;
    
    [[StoreManager sharedInstance] buyProduct:_unlockForever];
    
    self.isBusy = NO;
}

- (void)buyUnlock3Months
{
    if( self.isBusy )
        return;
    
    [[StoreManager sharedInstance] buyProduct:_unlock3Months];
    
    self.isBusy = NO;
}

- (void)buyUnlock1Month
{
    if( self.isBusy )
        return;
    
    [[StoreManager sharedInstance] buyProduct:_unlock1Month];
    
    self.isBusy = NO;
}

- (void)restore
{
    if( self.isBusy )
        return;
    
    [[StoreManager sharedInstance] restore];
    
    self.isBusy = NO;
}

#pragma mark - StoreManagerDelegate
- (void)storeManager:(StoreManager *)manager didReceiveInfoFor:(NSArray *)products
{
    if( [_unlockForever isReceivedInfo] && [_unlock3Months isReceivedInfo] && [_unlock1Month isReceivedInfo] )
    {
        [_buyButton setTitle:[_unlock1Month price] forState:UIControlStateNormal];

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveProductInfo object:nil];
    }
}

- (void)storeManager:(StoreManager *)manager didPurchaseProduct:(MProduct *)p withSuccess:(BOOL)isSuccess
{
    self.isBusy = NO;
    
    if( isSuccess )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidPurchaseProduct object:nil];
        [p save];
    }
}

- (void)storeManagerRestored:(StoreManager *)manager withSuccess:(BOOL)isSuccess
{
    self.isBusy = NO;
    
    /*
    if( isSuccess )
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidPurchaseProduct object:nil];
     */
}

- (void)storeManagerFinishedValidatingReceipt:(StoreManager *)manager withSuccess:(BOOL)isSuccess
{
    NSLog(@"Validated receipt(%d)", isSuccess);
    
    if( isSuccess )
    {
        NSLog(@"1 month: %@, 3 months: %@", _unlock1Month.expireDate, _unlock3Months.expireDate);
    }
}

/*
#pragma mark - Notification
- (void)onPurchased:(NSNotification *)notification
{
    if( _delegate != nil )
        [_delegate didUnlockAdditionalSounds:self];
}

- (void)onProductInfo:(NSNotification *)notification
{
    NSDictionary * userInfo = notification.userInfo;
    if( userInfo != nil )
    {
        NSString * price = [userInfo objectForKey:ProductIdForProVersion];
        if( price != nil )
            [_buyButton setTitle:price forState:UIControlStateNormal];
    }
}
*/
@end
