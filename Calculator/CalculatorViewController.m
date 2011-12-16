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
@property (nonatomic, strong) NSMutableDictionary *testVariableValues;
@end


@implementation CalculatorViewController

@synthesize fullOperationDisplay;
@synthesize variablesDisplay;
@synthesize display;

@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

-(CalculatorBrain *) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (NSMutableDictionary *) testVariableValues {
    if (!_testVariableValues) {
        _testVariableValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"x", @"1", @"a", @"2", @"b", @"3", nil];
    }
    return _testVariableValues;
}

-(void) clearEqualSignFromFullDisplay {
    if ([self.fullOperationDisplay.text hasSuffix:@"="]) {
        self.fullOperationDisplay.text = [self.fullOperationDisplay.text substringToIndex:self.fullOperationDisplay.text.length-1];
    }
}

-(void) updateDisplays {
    self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    
    NSMutableString *variables = [NSMutableString stringWithString:@""];
    for (NSString *variable in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        NSString *variableValue = [self.testVariableValues valueForKey:variable];
        if (variableValue) {
            [variables appendFormat:@"%@ = %@ ", variable, variableValue];
        }
    }
    self.variablesDisplay.text = variables;
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
    self.fullOperationDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
                                      //[self.fullOperationDisplay.text stringByAppendingFormat:@"%@ ", self.display.text];

}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self.brain pushVariable:sender.currentTitle];
    self.display.text = sender.currentTitle;
    self.fullOperationDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.userIsInTheMiddleOfEnteringANumber = NO;
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
        self.fullOperationDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
        //[self.fullOperationDisplay.text stringByAppendingFormat:@"%@ =", sender.currentTitle];
    }
}

- (IBAction)clearDisplay {
    self.display.text = @"0";
    self.fullOperationDisplay.text = @"";
    [self.brain clearCalculator];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)setVariableValues:(UIButton *)sender {
//    if ([sender.currentTitle isEqualToString:@"Test 1"]) {
//        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"x", @"1", @"a", @"2", @"b", @"3", nil ];
//    } else if ([sender.currentTitle isEqualToString:@"Test 2"]) {
//        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"x", @"0", @"a", @"-5", @"b", @"0.5", nil ];
//    } else if ([sender.currentTitle isEqualToString:@"Test 3"]) {
//        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"x", @"1", @"a", @"2", @"b", @"3", nil ];
//    }
    [self updateDisplays];
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
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
