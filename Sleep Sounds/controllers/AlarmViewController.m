//
//  AlarmViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 23/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "AlarmViewController.h"
#import "SwichView.h"
#import "MDatePickerView.h"
#import "FadeInSecondViewController.h"
#import "AlarmSoundViewController.h"

@interface AlarmViewController () <UITableViewDataSource, UITableViewDelegate, SwitchViewDelegate, MDatePickerViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *propertyTableView;
@property (strong, nonatomic) IBOutlet UIButton *clockButton;
@property (strong, nonatomic) IBOutlet UIButton *countdownButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timeSelectionViewConstraint;

@property (strong, nonatomic) IBOutlet MDatePickerView *datePickerView;

@end


@implementation AlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem * doneItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clear"]
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self action:@selector(onDone:)];
    doneItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = doneItem;
    
    _datePickerView.datePickerViewDelegate = self;
    if( _alarm.type == ALARM )
    {
        self.navigationItem.title = @"Alarm";
        self.tableViewConstraint.constant = 150;
    }
    else
    {
        self.navigationItem.title = @"Timer";
        self.tableViewConstraint.constant = 100;
    }
    
    _timeSelectionViewConstraint.constant = -220;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if( _timeSelectionViewConstraint.constant != 0 )
    {
        [UIView animateWithDuration:0.4 animations:^{
            _timeSelectionViewConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if( _alarm.countdownSec < 0 )
                [self showClock];
            else
                [self showCountdown];
        }];
    }
    else
    {
        [_propertyTableView reloadData];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController * viewController = (FadeInSecondViewController *)segue.destinationViewController;
    if( [viewController isKindOfClass:[FadeInSecondViewController class]] )
        ((FadeInSecondViewController *)viewController).alarm = _alarm;
    else if( [viewController isKindOfClass:[AlarmSoundViewController class]] )
        ((AlarmSoundViewController *)viewController).alarm = _alarm;
}

- (IBAction)prepareForUnWind:(UIStoryboardSegue *)segue
{
    
}

#pragma mark - Done & Save
- (void)onDone:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender
{
    if( _mode == ALARM_NEW )
        [[AlarmManager sharedInstance] addAlarm:_alarm];
    [[AlarmManager sharedInstance] saveAlarms];
    [_alarm calculateFireInterval];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_alarm.type==ALARM)?3:2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmPropertyCell * cell = nil;
    
    if( _alarm.type == ALARM )
    {
        switch( indexPath.row )
        {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"sound_id"];
                cell.subTitleLabel.text = self.alarm.name;
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_id"];
                cell.subTitleLabel.text = [self.alarm stringForFadeInSec];
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"snooze_id"];
                cell.switchView.isOn = self.alarm.snoozeEanbled;
                cell.switchView.delegate = self;
                break;
        }
    }
    else
    {
        switch( indexPath.row )
        {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"fadeout_id"];
                cell.subTitleLabel.text = [self.alarm stringForFadeInSec];
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"exitapp_id"];
                cell.switchView.isOn = self.alarm.exitApp;
                cell.switchView.delegate = self;
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Event
- (void)switchValueChanged:(SwichView *)switchView
{
    if( _alarm.type == ALARM )
        self.alarm.snoozeEanbled = switchView.isOn;
    else
        self.alarm.exitApp = switchView.isOn;
}

- (IBAction)onClock:(id)sender
{
    [self showClock];
}

- (void)showClock
{
    _clockButton.backgroundColor = [UIColor colorWithRed:0.007843f green:0.6941f blue:0.70588f alpha:1.0f];
    _countdownButton.backgroundColor = [UIColor colorWithRed:0.0196f green:0.6196f blue:0.63137f alpha:1.0f];
    _datePickerView.pickerMode = TIME_PICKER_MODE;
    _datePickerView.hour    = _alarm.hour;
    _datePickerView.minute  = _alarm.mins;
    _datePickerView.ampm    = _alarm.ampm;

    _alarm.countdownSec = -1;
}

- (IBAction)onCountdown:(id)sender
{
    [self showCountdown];
}

- (void)showCountdown
{
    _countdownButton.backgroundColor = [UIColor colorWithRed:0.007843f green:0.6941f blue:0.70588f alpha:1.0f];
    _clockButton.backgroundColor = [UIColor colorWithRed:0.0196f green:0.6196f blue:0.63137f alpha:1.0f];
    _datePickerView.pickerMode = COUNTDOWN_PICKER_MODE;
    
    if( _alarm.countdownSec < 0 )
        _alarm.countdownSec = 2*3600;
    _datePickerView.countdown = _alarm.countdownSec;
}

#pragma mark - MDatePickerViewDelegate
- (void)timeChanged:(MDatePickerView *)pickerView
{
    _alarm.hour = pickerView.hour;
    _alarm.mins = pickerView.minute;
    _alarm.ampm = pickerView.ampm;
}

- (void)countdownChanged:(MDatePickerView *)pickerView
{
    _alarm.countdownSec = pickerView.countdown;
}

@end

@implementation AlarmPropertyCell
@end