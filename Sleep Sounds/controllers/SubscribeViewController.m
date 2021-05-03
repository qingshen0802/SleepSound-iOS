//
//  SubscribeViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 10/2/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import "SubscribeViewController.h"
#import "UnlockController.h"

@interface SubscribeViewController ()
@property (strong, nonatomic) IBOutlet UILabel *unlockFoveverPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *unlock3monthPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *unlock1monthPriceLabel;

@property (strong, nonatomic) IBOutlet UIButton *unlockForeverButton;
@property (strong, nonatomic) IBOutlet UIButton *unlock3monthsButton;
@property (strong, nonatomic) IBOutlet UIButton *unlock1monthButton;


@end

@implementation SubscribeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePriceLabels:)
                                                 name:kNotificationDidReceiveProductInfo
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchasedProduct:)
                                                 name:kNotificationDidPurchaseProduct
                                               object:nil];
    
    [self updatePriceLabels:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDidReceiveProductInfo
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDidPurchaseProduct
                                                  object:nil];
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

- (void)updatePriceLabels:(NSNotification *)n
{
    MProduct * product;
    
    product = [UnlockController sharedInstance].unlockForever;
    if( [product isReceivedInfo] )
        _unlockFoveverPriceLabel.text = [product price];
    
    product = [UnlockController sharedInstance].unlock3Months;
    if( [product isReceivedInfo] )
        _unlock3monthPriceLabel.text = [product price];
    
    product = [UnlockController sharedInstance].unlock1Month;
    if( [product isReceivedInfo] )
        _unlock1monthPriceLabel.text = [product price];
}

- (void)purchasedProduct:(NSNotification *)n
{
    [self onClose:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Events
- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onBuyUnlockForever:(id)sender
{
    [[UnlockController sharedInstance] buyUnlockForever];
    
    [self disableBuyButtons];
}

- (IBAction)onBuyUnlock3Months:(id)sender
{
    [[UnlockController sharedInstance] buyUnlock3Months];
    
    [self disableBuyButtons];
}

- (IBAction)onBuyUnlock1Month:(id)sender
{
    [[UnlockController sharedInstance] buyUnlock1Month];
    
    [self disableBuyButtons];
}

- (void)disableBuyButtons
{
    self.unlockForeverButton.enabled = NO;
    self.unlock3monthsButton.enabled = NO;
    self.unlock1monthButton.enabled = NO;
}

- (IBAction)onHealthTap:(id)sender
{
    
}

@end
