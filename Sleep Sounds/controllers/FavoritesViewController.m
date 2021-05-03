//
//  FavoritesViewController.m
//  Sleep Sounds
//
//  Created by Ditriol Wei on 27/8/15.
//  Copyright (c) 2015 Zen Labs LLC. All rights reserved.
//

#import "FavoritesViewController.h"
#import "SWRevealViewController.h"
#import "FavoriteGroupCell.h"
#import "Favorite.h"
#import "FavoriteEditViewController.h"
#import "MSoundManager.h"
#import "ImageCache.h"

@interface FavoritesViewController () <UITableViewDataSource, UITableViewDelegate, FavoriteEditViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray * favorites;
@property (strong, nonatomic) Favorite * currentFavorite;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) UIBarButtonItem * editItem;

@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.editItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen"] style:UIBarButtonItemStyleBordered target:self action:@selector(onEdit:)];
    _editItem.tintColor = [UIColor darkGrayColor];
    UIBarButtonItem * addItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStyleBordered target:self action:@selector(onAdd:)];
    addItem.tintColor = [UIColor darkGrayColor];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_editItem, addItem, nil];
    
    SWRevealViewController * revealController = self.revealViewController;
    _tableViewConstraint.constant = revealController.rightViewRevealWidth;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.favorites = [NSMutableArray arrayWithArray:[Favorite availableFavorites]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    [_tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"edit_favorite"] )
    {
        UINavigationController * navController = segue.destinationViewController;
        FavoriteEditViewController * controller = [navController.viewControllers objectAtIndex:0];
        controller.favorite = _currentFavorite;
        controller.isEdit = YES;
        controller.delegate = self;
    }
    else if( [segue.identifier isEqualToString:@"add_favorite"] )
    {
        UINavigationController * navController = segue.destinationViewController;
        FavoriteEditViewController * controller = [navController.viewControllers objectAtIndex:0];
        controller.favorite = _currentFavorite;
        controller.isEdit = NO;
        controller.delegate = self;
    }
}

#pragma mark - Button Events

- (void)onEdit:(id)sender
{
    if( _tableView.isEditing )
    {
        [_tableView setEditing:NO animated:YES];
        [_editItem setImage:[UIImage imageNamed:@"pen"]];
    }
    else
    {
        [_tableView setEditing:YES animated:YES];
        [_editItem setImage:[UIImage imageNamed:@"check"]];
    }
}

- (void)onAdd:(id)sender
{
    NSArray * playingSounds = [[MSoundManager sharedInstance] playingSounds];
    
    if( playingSounds==nil || [playingSounds count]==0 )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Empty Selection!"
                                                         message:@"In order to save your current selection as a favorite, you must first select some sounds."
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    self.currentFavorite = [[Favorite alloc] init];
    _currentFavorite.soundIds = [NSMutableArray array];
    for( MSound * s in playingSounds )
        [_currentFavorite.soundIds addObject:s.uniqueId];
    
    [self performSegueWithIdentifier:@"add_favorite" sender:sender];
}

#pragma mark - FavoriteEditViewControllerDelegate
- (void)favoriteEditViewControllerDidChange:(FavoriteEditViewController *)controller
{
    if( !controller.isEdit )
        [_favorites addObject:controller.favorite];
    [Favorite saveFavorites:_favorites];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    
    Favorite * favorite = [_favorites objectAtIndex:indexPath.row];
    cell.groupNameLabel.text = favorite.name;
    
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
    
    [cell loadImages:images forNames:names];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( _tableView.isEditing )
    {
        //Edit
        self.currentFavorite = [_favorites objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"edit_favorite" sender:nil];
    }
    else
    {
        //Play
        self.currentFavorite = [_favorites objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificatonPlayFavorite
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:_currentFavorite forKey:kNotificatonFavoritekey]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Favorite * favorite = [_favorites objectAtIndex:indexPath.row];
    return [FavoriteGroupCell heightOfCellWithImageNum:favorite.soundIds.count];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [_favorites exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];

    /*
    Favorite * favorite = [_favorites objectAtIndex:sourceIndexPath.row];
    [_favorites removeObjectAtIndex:sourceIndexPath.row];
    [_favorites insertObject:favorite atIndex:destinationIndexPath.row];
    */
     
    [Favorite saveFavorites:_favorites];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        [_favorites removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [Favorite saveFavorites:_favorites];
    }
}

@end
