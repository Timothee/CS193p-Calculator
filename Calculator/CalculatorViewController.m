//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Timothée Boucher on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end


@implementation CalculatorViewController
@synthesize fullOperationDisplay;

@synthesize display, userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

-(CalculatorBrain *) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}
-(void) clearEqualSignFromFullDisplay {
    if ([self.fullOperationDisplay.text hasSuffix:@"="]) {
        self.fullOperationDisplay.text = [self.fullOperationDisplay.text substringToIndex:self.fullOperationDisplay.text.length-1];
    }
}

- (IBAction)digitPressed:(UIButton *)sender {
    [self clearEqualSignFromFullDisplay];
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)dotPressed {
    [self clearEqualSignFromFullDisplay];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        }
    } else {
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.fullOperationDisplay.text = [self.fullOperationDisplay.text stringByAppendingFormat:@"%@ ", self.display.text];

}


- (IBAction)operationPressed:(UIButton *)sender {
    [self clearEqualSignFromFullDisplay];
    
    if (self.userIsInTheMiddleOfEnteringANumber && [sender.currentTitle isEqualToString:@"+/-"]) {
        if ([self.display.text hasPrefix:@"-"]) {
            self.display.text = [self.display.text substringFromIndex:1];
        } else {
            self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
        }
    } else {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            [self enterPressed];
        }
        double result = [self.brain performOperation:sender.currentTitle];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        self.fullOperationDisplay.text = [self.fullOperationDisplay.text stringByAppendingFormat:@"%@ =", sender.currentTitle];
    }
}

- (IBAction)clearDisplay {
    self.display.text = @"0";
    self.fullOperationDisplay.text = @"";
    [self.brain clearCalculator];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (IBAction)backspace {
    self.display.text = [self.display.text substringToIndex:[self.display.text length]-1];
    if (self.display.text.length == 0) {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}



- (void)viewDidUnload {
    [self setFullOperationDisplay:nil];
    [super viewDidUnload];
}
@end
