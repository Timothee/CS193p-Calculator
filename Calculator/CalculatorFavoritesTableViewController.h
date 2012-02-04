//
//  FavoriteTableViewController.h
//  Calculator
//
//  Created by Timothée Boucher on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorFavoritesTableViewController;

@protocol FavoriteTableViewControllerDelegate <NSObject>
@optional
-(void)favoriteTableViewController:(CalculatorFavoritesTableViewController *)sender
          didSelectFavoriteProgram:(id)program;
-(void)favoriteTableViewController:(CalculatorFavoritesTableViewController *)sender
          didDeleteFavoriteProgram:(id)program;
@end

@interface CalculatorFavoritesTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, weak) id <FavoriteTableViewControllerDelegate> delegate;

@end
