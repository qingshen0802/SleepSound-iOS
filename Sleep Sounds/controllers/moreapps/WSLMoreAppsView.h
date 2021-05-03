//
//  WSLMoreAppsView.h
//  C25K
//
//  Created by Aleksey Mazurenko on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"

@protocol WSLMoreAppsViewDelegate;
@interface WSLMoreAppsView : UIView <UITextFieldDelegate, UIScrollViewDelegate, ATMHudDelegate>
{
	ATMHud *hud;
    
    IBOutlet UIButton *featuredBtn;
    IBOutlet UILabel *featuredAppLbl;
    IBOutlet UILabel *appTitleLbl;
    IBOutlet UILabel *featuredLbl;
    IBOutlet UIImageView *backgroundImage;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *bottomTexts;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *joinTexts;
@property (strong, nonatomic) IBOutlet UILabel *joinTitle;
@property (strong, nonatomic) IBOutlet UILabel *dailyTitle;

@property (retain, nonatomic) IBOutlet UILabel *labelTips;
@property (retain, nonatomic) IBOutlet UILabel *labelQuotes;
@property (retain, nonatomic) IBOutlet UITextField *tfEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *registeredView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *standardView;

@property (assign, nonatomic) BOOL isOpened;
@property (assign, nonatomic) id<WSLMoreAppsViewDelegate> delegate;

+ (WSLMoreAppsView *)instance;

- (void)show;

- (IBAction)btnRegisterClicked:(id)sender;
- (IBAction)btnCloseClicked:(id)sender;
- (IBAction)linkToApp:(id)sender;

@end

@protocol WSLMoreAppsViewDelegate <NSObject>
@optional
- (void)WSLMoreAppsViewClosed:(WSLMoreAppsView *)view;
@end



@interface NSData(MD5)
- (NSString *)MD5;
@end


@interface NSDictionary (Data)
+ (NSDictionary *)dictionaryWithData:(NSData *)data;
- (NSData *)dataRepresentation;
@end
