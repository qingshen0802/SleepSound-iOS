//
//  FadeInSecondViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 29/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "FadeInSecondViewController.h"
#import "Alarm.h"

@interface FadeInSecondViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FadeInSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FadeInSecondCell * cell = nil;
    
    switch( indexPath.row )
    {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_none"];
            cell.stateView.hidden = (_alarm.fadeInSec>0);
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_15seconds"];
            cell.stateView.hidden = (_alarm.fadeInSec!=15);
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_30seconds"];
            cell.stateView.hidden = (_alarm.fadeInSec!=30);
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_1minute"];
            cell.stateView.hidden = (_alarm.fadeInSec!=60);
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_2minutes"];
            cell.stateView.hidden = (_alarm.fadeInSec!=120);
            break;
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_5minutes"];
            cell.stateView.hidden = (_alarm.fadeInSec!=300);
            break;
        case 6:
            cell = [tableView dequeueReusableCellWithIdentifier:@"fadein_10minutes"];
            cell.stateView.hidden = (_alarm.fadeInSec!=600);
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch( indexPath.row )
    {
        case 0:
            _alarm.fadeInSec = 0;
            break;
        case 1:
            _alarm.fadeInSec = 15;
            break;
        case 2:
            _alarm.fadeInSec = 30;
            break;
        case 3:
            _alarm.fadeInSec = 60;
            break;
        case 4:
            _alarm.fadeInSec = 120;
            break;
        case 5:
            _alarm.fadeInSec = 300;
            break;
        case 6:
            _alarm.fadeInSec = 600;
            break;
    }
    
    [tableView reloadData];
}

@end

@implementation FadeInSecondCell
@end