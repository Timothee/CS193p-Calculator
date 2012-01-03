//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Timothée Boucher on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *fullOperationDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variablesDisplay;

@end
