//
//  FavoriteTableViewController.h
//  Calculator
//
//  Created by Timothée Boucher on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoriteTableViewController;

@protocol FavoriteTableViewControllerDelegate
-(void)favoriteTableViewController:(FavoriteTableViewController *)sender
          didDeleteFavoriteProgram:(id)program;
-(NSArray *)favoritesForFavoriteTableViewController:(FavoriteTableViewController *)sender;
@optional
-(void)favoriteTableViewController:(FavoriteTableViewController *)sender
          didSelectFavoriteProgram:(id)program;
@end

@interface FavoriteTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, weak) id <FavoriteTableViewControllerDelegate> delegate;

@end
