//
//  AlarmTimerViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 19/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "AlarmTimerViewController.h"
#import "AlarmViewController.h"
#import "AlarmManager.h"
#import "AppDefine.h"

@interface AlarmTimerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIBarButtonItem * editItem;
@property (strong, nonatomic) Alarm * currentAlarm;

@property (strong, nonatomic) IBOutlet UITableView *alarmTableView;
@property (strong, nonatomic) IBOutlet UIView *SelectItemView;
@property (strong, nonatomic) IBOutlet UIView *selectItemBackView;

@end

@implementation AlarmTimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen"] style:UIBarButtonItemStyleBordered target:self action:@selector(onEdit:)];
    _editItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem * addItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStyleBordered target:self action:@selector(onAdd:)];
    addItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_editItem, addItem, nil];
    
    UIBarButtonItem * doneItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clear"] style:UIBarButtonItemStyleBordered target:self action:@selector(onDone:)];
    doneItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = doneItem;
    
    _selectItemBackView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Status Bar - White
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [_alarmTableView reloadData];
}

- (void)onEdit:(id)sender
{
    if( _alarmTableView.isEditing )
    {
        [_alarmTableView setEditing:NO animated:YES];
        [_editItem setImage:[UIImage imageNamed:@"pen"]];
    }
    else
    {
        [_alarmTableView setEditing:YES animated:YES];
        [_editItem setImage:[UIImage imageNamed:@"check"]];
    }
    
    [_alarmTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)onAdd:(id)sender
{
    _SelectItemView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _selectItemBackView.hidden = NO;
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.4 options:UIViewAnimationOptionTransitionNone animations:^{
        _SelectItemView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:NULL];
}

- (void)onDone:(id)sender
{
    if( [self.navigationController.viewControllers count] < 2 )
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
    [[AlarmManager sharedInstance] saveAlarms];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if( [segue.identifier isEqualToString:@"AlarmViewController"] )
    {
        AlarmViewController * alarmViewController = (AlarmViewController *)segue.destinationViewController;
        
        if( _currentAlarm == nil )
        {
            alarmViewController.mode = ALARM_NEW;
            alarmViewController.alarm = [[Alarm alloc] initAlarm];
        }
        else
        {
            alarmViewController.mode = ALARM_EDIT;
            alarmViewController.alarm = _currentAlarm;
        }
    }
    else if( [segue.identifier isEqualToString:@"TimerViewController"] )
    {
        AlarmViewController * alarmViewController = (AlarmViewController *)segue.destinationViewController;
        if( _currentAlarm == nil )
        {
            alarmViewController.mode = ALARM_NEW;
            alarmViewController.alarm = [[Alarm alloc] initTimer];
        }
        else
        {
            alarmViewController.mode = ALARM_EDIT;
            alarmViewController.alarm = _currentAlarm;
        }
    }
}

#pragma mark - Selection
- (IBAction)onSelectedAlarm:(id)sender
{
    self.selectItemBackView.hidden = YES;
    self.currentAlarm = nil;
    [self performSelector:@selector(gotoAlarmView) withObject:nil afterDelay:0.5];
}

- (IBAction)onSelectedTimer:(id)sender
{
    self.selectItemBackView.hidden = YES;
    self.currentAlarm = nil;
    [self performSelector:@selector(gotoTimerView) withObject:nil afterDelay:0.5];
}

- (IBAction)onCanceledSelection:(id)sender
{
    _selectItemBackView.hidden = YES;
}

- (void)gotoAlarmView
{
    [self performSegueWithIdentifier:@"AlarmViewController" sender:nil];
}

- (void)gotoTimerView
{
    [self performSegueWithIdentifier:@"TimerViewController" sender:nil];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[AlarmManager sharedInstance].availableAlarms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmCell * cell;
    
    //Create Cell
    Alarm * alarm = [[AlarmManager sharedInstance].availableAlarms objectAtIndex:indexPath.row];
    if( alarm.type == ALARM )
        cell = [tableView dequeueReusableCellWithIdentifier:@"alarm_identifier" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"timer_identifier" forIndexPath:indexPath];

    cell.alarm = alarm;
    cell.switchView.delegate = cell;
    
    if( tableView.isEditing )
        cell.switchView.hidden = YES;
    else
        cell.switchView.hidden = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( [tableView isEditing] )
    {
        self.currentAlarm = [[AlarmManager sharedInstance].availableAlarms objectAtIndex:indexPath.row];
        
        if(self.currentAlarm.type == ALARM )
            [self gotoAlarmView];
        else
            [self gotoTimerView];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[AlarmManager sharedInstance] exchangeAlarmIndex:sourceIndexPath.row withIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        Alarm * alarm = [[[AlarmManager sharedInstance] availableAlarms] objectAtIndex:indexPath.row];
        [[AlarmManager sharedInstance] removeAlarm:alarm];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView.editing )
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

@end

@implementation AlarmCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAlarm:(Alarm *)a
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if( a != nil )
    {
        //Show/Hide Switch
        _switchView.isOn = a.enabled;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlarmTimer:) name:kAlarmCountDownNotification object:a];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlarmFire:) name:kAlarmFireNotification object:a];
    }
    
    _alarm = a;
    
    _mainTitleLabel.text = [_alarm stringForTime];
}

- (void)onAlarmTimer:(NSNotification *)n
{
    _mainTitleLabel.text = [_alarm stringForTime];
}

- (void)onAlarmFire:(NSNotification *)n
{
    if( _alarm.enabled )
        _switchView.isOn = YES;
    else
        _switchView.isOn = NO;
    
    _mainTitleLabel.text = [_alarm stringForTime];
}

- (void)switchValueChanged:(SwichView *)switchView
{
    _alarm.enabled = switchView.isOn;
    _mainTitleLabel.text = [_alarm stringForTime];
}

@end