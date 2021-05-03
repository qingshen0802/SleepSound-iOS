//
//  MDatePickerView.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 28/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "MDatePickerView.h"
#import "Utils.h"

@interface MDatePickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSMutableArray * hourTitles;
@property (strong, nonatomic) NSMutableArray * minuTitles;
@property (strong, nonatomic) NSMutableArray * ampmTitles;
@property (strong, nonatomic) NSString * attrHours;
@property (strong, nonatomic) NSString * attrMinut;

@end

@implementation MDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self != nil )
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setup];
    }
    
    return self;
}

NSAttributedString * attrString(NSString * s)
{
    NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:s];
    [attrS addAttribute:NSFontAttributeName value:[Utils fontMyriadProLightWithSize:25] range:NSMakeRange(0, s.length)];
    [attrS addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, s.length)];
    return attrS;
}

- (void)setup
{
    self.hourTitles = [NSMutableArray array];
    for( int i = 0 ; i < 24 ; i++ )
        [_hourTitles addObject:[NSString stringWithFormat:@"%d", i]];

    self.minuTitles = [NSMutableArray array];
    for( int i = 0 ; i < 60 ; i++ )
        [_minuTitles addObject:[NSString stringWithFormat:@"%d", i]];
    
    self.ampmTitles = [NSMutableArray arrayWithObjects:@"AM", @"PM", nil];
    self.attrHours  = @"hours";
    self.attrMinut  = @"mins";
    
    self.dataSource = self;
    self.delegate = self;
}

#pragma mark - Public
- (void)setPickerMode:(NSInteger)mode
{
    _pickerMode = mode;
    
    [self reloadAllComponents];
}

- (void)setHour:(NSInteger)h
{
    _hour = h;
    if( _pickerMode == TIME_PICKER_MODE )
        [self selectRow:h-1 inComponent:0 animated:YES];
}

- (void)setMinute:(NSInteger)m
{
    _minute = m;
    if( _pickerMode == TIME_PICKER_MODE )
        [self selectRow:m inComponent:1 animated:YES];
}

- (void)setAmpm:(NSInteger)ap
{
    _ampm = ap;
    if( _pickerMode == TIME_PICKER_MODE )
        [self selectRow:ap inComponent:2 animated:YES];
}

- (void)setCountdown:(NSInteger)sec
{
    _countdown = sec;
    if( _pickerMode == COUNTDOWN_PICKER_MODE )
    {
        NSInteger h = sec/3600;
        NSInteger m = (sec%3600)/60;
        
        [self selectRow:h inComponent:0 animated:YES];
        [self selectRow:m inComponent:2 animated:YES];
    }
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger num = 0;
    if( _pickerMode == TIME_PICKER_MODE )
        num = 3;
    else if( _pickerMode == COUNTDOWN_PICKER_MODE )
        num = 4;
    
    return num;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger num = 0;
    if( _pickerMode == TIME_PICKER_MODE )
    {
        switch( component )
        {
            case 0:
                num = 12;
                break;
            case 1:
                num = 60;
                break;
            case 2:
                num = 2;
                break;
        }
    }
    else if( _pickerMode == COUNTDOWN_PICKER_MODE )
    {
        switch( component )
        {
            case 0:
                num = 24;
                break;
            case 1:
                num = 1;
                break;
            case 2:
                num = 60;
                break;
            case 3:
                num = 1;
                break;
        }
    }
    
    return num;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * label;
    if( view == nil )
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        label.font = [Utils fontMyriadProLightWithSize:30];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    }
    else
    {
        label = (UILabel *)[view viewWithTag:1];
    }
    
    if( _pickerMode == TIME_PICKER_MODE )
    {
        switch( component )
        {
            case 0:
                label.text = [_hourTitles objectAtIndex:row+1];
                label.textAlignment = NSTextAlignmentRight;
                break;
            case 1:
                label.text = [_minuTitles objectAtIndex:row];
                label.textAlignment = NSTextAlignmentCenter;
                break;
            case 2:
                label.text = [_ampmTitles objectAtIndex:row];
                label.textAlignment = NSTextAlignmentLeft;
                break;
        }
    }
    else if( _pickerMode == COUNTDOWN_PICKER_MODE )
    {
        switch( component )
        {
            case 0:
                label.text = [_hourTitles objectAtIndex:row];
                label.textAlignment = NSTextAlignmentRight;
                break;
            case 1:
                label.text = _attrHours;
                label.font = [Utils fontMyriadProLightWithSize:18];
                label.textAlignment = NSTextAlignmentLeft;
                break;
            case 2:
                label.text = [_minuTitles objectAtIndex:row];
                label.textAlignment = NSTextAlignmentRight;
                break;
            case 3:
                label.text = _attrMinut;
                label.font = [Utils fontMyriadProLightWithSize:18];
                label.textAlignment = NSTextAlignmentLeft;
                break;
        }
    }
    
    return view;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    CGFloat w = 40;
//    CGFloat width = pickerView.bounds.size.width;
//    if( _pickerMode == TIME_PICKER_MODE )
//    {
//        switch( component )
//        {
//            case 0:
//                w = width * 0.35;
//                break;
//            case 1:
//                w = width * 0.30;
//                break;
//            case 2:
//                w = width * 0.35;
//                break;
//        }
//    }
//    else if( _pickerMode == COUNTDOWN_PICKER_MODE )
//    {
//        switch( component )
//        {
//            case 0:
//                w = width * 0.25;
//                break;
//            case 1:
//                w = width * 0.25;
//                break;
//            case 2:
//                w = width * 0.25;
//                break;
//            case 3:
//                w = width * 0.25;
//                break;
//        }
//    }
//    
//    return w;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if( _pickerMode == TIME_PICKER_MODE )
    {
        switch( component )
        {
            case 0:
                _hour = row+1;
                break;
            case 1:
                _minute = row;
                break;
            case 2:
                _ampm = row;
                break;
        }
        
        if( _datePickerViewDelegate != nil && [_datePickerViewDelegate respondsToSelector:@selector(timeChanged:)] )
            [_datePickerViewDelegate timeChanged:self];
        
    }
    else if( _pickerMode == COUNTDOWN_PICKER_MODE )
    {
        NSInteger h = [self selectedRowInComponent:0];
        NSInteger m = [self selectedRowInComponent:2];
        _countdown = h*3600+m*60;
        
        if( _datePickerViewDelegate != nil && [_datePickerViewDelegate respondsToSelector:@selector(countdownChanged:)] )
            [_datePickerViewDelegate countdownChanged:self];
    }
}

@end
