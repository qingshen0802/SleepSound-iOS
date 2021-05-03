//
//  SwichView.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "SwichView.h"

@interface SwichView ()
@property (strong, nonatomic) UIImageView * backImageView;
@property (strong, nonatomic) UIImageView * knobImageView;
@end

@implementation SwichView{
    BOOL isKnobDragging;
}

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

- (void)setup
{
    CGSize size = self.bounds.size;
    self.layer.cornerRadius = size.height/2;
    self.clipsToBounds = YES;
    
    self.backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_backImageView];
    
    self.knobImageView = [[UIImageView alloc] initWithFrame:[self rectOfKnob]];
    [self addSubview:_knobImageView];
    
    isKnobDragging = NO;

    self.backImageView.image = [UIImage imageNamed:@"g_back"];
    self.isOn = YES;
}

- (void)setIsOn:(BOOL)on
{
    if( _isOn == on )
        return;

    _isOn = on;
    [self update];
}

- (void)update
{
    [UIView animateWithDuration:0.2 animations:^{
        _knobImageView.frame = [self rectOfKnob];
    } completion:^(BOOL finished) {
        if( _isOn )
        {
            //self.backgroundColor = [UIColor colorWithRed:0.745f green:0.839f blue:0.184f alpha:1.0f];
            _knobImageView.image = [UIImage imageNamed:@"switch_on"];
            _backImageView.image = [UIImage imageNamed:@"g_back"];
        }
        else
        {
            //self.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
            _knobImageView.image = [UIImage imageNamed:@"switch_off"];
            _backImageView.image = [UIImage imageNamed:@"d_back"];
        }
    }];
}

- (CGRect)rectOfKnob
{
    CGSize s = self.bounds.size;
    CGRect r;
    r.size.width  = s.height-4;
    r.size.height = s.height-4;
    r.origin.x = (_isOn?s.width-r.size.width-2:2);
    r.origin.y = 2;
    
    return r;
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    CGRect r = _knobImageView.frame;
    if( CGRectContainsPoint(r, p) )
        isKnobDragging = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( isKnobDragging )
    {
        CGPoint p = [[touches anyObject] locationInView:self];
        
        CGRect r = _knobImageView.frame;
        CGPoint c = _knobImageView.center;
        r.origin.x += (p.x-c.x);
        if( r.origin.x < 2 )
            r.origin.x = 2;
        if( r.origin.x > self.bounds.size.width-r.size.width-2 )
            r.origin.x = self.bounds.size.width-r.size.width-2;
        _knobImageView.frame = r;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    if( p.x > self.bounds.size.width/2 )
        self.isOn = YES;
    else
        self.isOn = NO;
    
    if( _delegate != nil && [_delegate respondsToSelector:@selector(switchValueChanged:)] )
        [_delegate switchValueChanged:self];
    
    isKnobDragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    if( p.x > self.bounds.size.width/2 )
        self.isOn = YES;
    else
        self.isOn = NO;
    
    if( _delegate != nil && [_delegate respondsToSelector:@selector(switchValueChanged:)] )
        [_delegate switchValueChanged:self];
    
    isKnobDragging = NO;
}

@end
