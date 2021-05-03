//
//  FavoriteEditViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/9/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "FavoriteEditViewController.h"
#import "MSoundManager.h"
#import "Utils.h"
#import "ImageCache.h"

@interface FavoriteEditViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *enterNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FavoriteEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( _isEdit )
        self.navigationItem.title = @"Edit Favorite";
    else
        self.navigationItem.title = @"Add Favorite";
    _nameLabel.text = _favorite.name;
    _enterNameTextField.text = _favorite.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_enterNameTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadInfo];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadInfo
{
    NSMutableArray * sounds = [NSMutableArray array];
    for( NSString * Id in _favorite.soundIds )
    {
        MSound * s = [[MSoundManager sharedInstance] soundForId:Id];
        if( s != nil )
            [sounds addObject:s];
    }
    
    CGSize s = _scrollView.bounds.size;
    CGRect r1 = CGRectMake(0, 0, s.width/2, 80);
    CGRect r2 = CGRectMake(s.width/2+1, 0, s.width/2-1, 80);
    CGRect r3 = CGRectMake(20, 30, s.width/2-30, 20);
    CGRect r4 = CGRectMake(s.width/2+1+20, 30, s.width/2-1-30, 20);
    
    for( NSInteger i = 0 ; i < [sounds count] ; i++ )
    {
        MSound * sound = [sounds objectAtIndex:i];
        UIImage * image = [[ImageCache sharedInstance] imageNamed:sound.background];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        UILabel * label = [[UILabel alloc] init];
        label.text = sound.name;
        label.font = [Utils fontMyriadProLightWithSize:18];
        label.textColor = [UIColor whiteColor];

        [_scrollView addSubview:imageView];
        [_scrollView addSubview:label];
        
        if( i % 2 == 0 )
        {
            CGRect r11 = r1;
            r11.origin.x = r1.origin.x - s.width;
            imageView.frame = r11;
            CGRect r31 = r3;
            r31.origin.x = r3.origin.x - s.width;
            label.frame = r31;
            
            [UIView animateWithDuration:0.3 delay:i*0.1 usingSpringWithDamping:0.6 initialSpringVelocity:5 options:0 animations:^{
                CGRect r12 = imageView.frame;
                r12.origin.x += s.width;
                imageView.frame = r12;

                CGRect r32 = label.frame;
                r32.origin.x += s.width;
                label.frame = r32;
            } completion:NULL];

            r1.origin.y += (r1.size.height+1);
            r3.origin.y += (r1.size.height+1);
        }
        else
        {
            CGRect r21 = r2;
            r21.origin.x = r2.origin.x - s.width;
            imageView.frame = r21;
            CGRect r41 = r4;
            r41.origin.x = r4.origin.x - s.width;
            label.frame = r41;
            
            [UIView animateWithDuration:0.3 delay:i*0.1 usingSpringWithDamping:0.6 initialSpringVelocity:5 options:0 animations:^{
                CGRect r22 = imageView.frame;
                r22.origin.x += s.width;
                imageView.frame = r22;
            
                CGRect r42 = label.frame;
                r42.origin.x += s.width;
                label.frame = r42;
            } completion:NULL];
            
            r2.origin.y += (r2.size.height+1);
            r4.origin.y += (r2.size.height+1);
        }
    }
    
    _scrollView.contentSize = CGSizeMake(s.width, r1.origin.y);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textDidChange:(NSNotification *)notification
{
    _nameLabel.text = _enterNameTextField.text;
}

#pragma mark - Button Events
- (IBAction)onClose:(id)sender
{
    if( [self.navigationController.viewControllers count] == 1 )
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCheck:(id)sender
{
    _favorite.name = _nameLabel.text;
    
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(favoriteEditViewControllerDidChange:)] )
        [_delegate favoriteEditViewControllerDidChange:self];
    
    [self onClose:sender];
}

@end
