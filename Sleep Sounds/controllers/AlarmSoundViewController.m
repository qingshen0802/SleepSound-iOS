//
//  AlarmSoundViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 29/10/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "AlarmSoundViewController.h"
#import "Alarm.h"
#import "FavoriteGroupCell.h"
#import "Favorite.h"
#import "MSoundManager.h"
#import "ImageCache.h"

@interface AlarmSoundViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *favoriteTableView;
@property (strong, nonatomic) NSArray * favorites;
@end

@implementation AlarmSoundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.favorites = [Favorite availableFavorites];
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
    NSInteger num = 1;
    
    if( _favorites != nil )
        num += [_favorites count];
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if( indexPath.row == 0 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"use_current_mix_selection" forIndexPath:indexPath];
        ((UseCurrentMixSelectionCell *)cell).checkmark.hidden = (_alarm.soundId!=nil);
    }
    else
    {
        FavoriteGroupCell * groupCell = [tableView dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
        
        Favorite * favorite = [_favorites objectAtIndex:indexPath.row-1];
        groupCell.groupNameLabel.text = favorite.name;
        groupCell.checkmark.hidden = ![_alarm.soundId isEqualToString:favorite.uniqueId];
        
        NSMutableArray * images = [NSMutableArray array];
        NSMutableArray * names  = [NSMutableArray array];
        for( NSString * Id in favorite.soundIds )
        {
            MSound * s = [[MSoundManager sharedInstance] soundForId:Id];
            UIImage * image = [[ImageCache sharedInstance] imageNamed:s.background];
            if( image != nil )
            {
                [images addObject:image];
                [names addObject:s.name];
            }
        }
        
        [groupCell loadImages:images forNames:names];
        
        return groupCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
        return 50;
    
    Favorite * favorite = [_favorites objectAtIndex:indexPath.row-1];
    return [FavoriteGroupCell heightOfCellWithImageNum:favorite.soundIds.count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.row == 0 )
        _alarm.soundId = nil;
    else
    {
        Favorite * favorite = [_favorites objectAtIndex:indexPath.row-1];
        _alarm.soundId = favorite.uniqueId;
    }
    
    [tableView reloadData];
}

@end

@implementation UseCurrentMixSelectionCell
@end