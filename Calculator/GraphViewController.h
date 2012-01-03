//
//  GraphViewController.h
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphingCalculatorView.h"

@interface GraphViewController : UIViewController

@property (nonatomic, strong) NSArray *program;
@property (nonatomic, weak) IBOutlet UILabel *functionDisplay;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@end
