//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Timothée Boucher on 11/30/11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "CalculatorGraphViewController.h"

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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"graphFunction.portrait"] ||
        [segue.identifier isEqualToString:@"graphFunction.landscape"]) {
        [segue.destinationViewController setProgram:[self.brain.program copy]];
    }
}

-(CalculatorBrain *) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

-(NSMutableDictionary *) testVariableValues {
    if (!_testVariableValues) {
        _testVariableValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat:1.0], @"a", [NSNumber numberWithFloat:2.0], @"b", [NSNumber numberWithFloat:3.0], @"x", nil];
    }
    return _testVariableValues;
}

-(void) clearEqualSignFromFullDisplay {
    if ([self.fullOperationDisplay.text hasSuffix:@"="]) {
        self.fullOperationDisplay.text = [self.fullOperationDisplay.text substringToIndex:self.fullOperationDisplay.text.length-1];
    }
}


// Returns the string of all variables currently used with their value
-(NSString *) variablesString {
    NSMutableString *variablesString = [NSMutableString string];
    NSSet *variablesUsedInProgram = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    
    for (NSString *variable in self.testVariableValues) {
        if ([variablesUsedInProgram containsObject:variable]) {
            [variablesString appendFormat:@"%@ = %@  ", variable, [self.testVariableValues valueForKey:variable]];
        }
    }
    return variablesString;
}

// Shortcut to update all displays
-(void)updateDisplays:(NSString *)mainDisplayText {
    if (mainDisplayText) {
        self.display.text = mainDisplayText;
    } else {
        id programValue = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
        if ([programValue isKindOfClass: [NSNumber class]]) {
           self.display.text = [NSString stringWithFormat:@"%@", [programValue stringValue]];
        } else if ([programValue isKindOfClass:[NSString class]]) {
            self.display.text = programValue;
        } else { // default case means stack is empty
            self.display.text = @"0";
        }
    }
    self.fullOperationDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.variablesDisplay.text = [self variablesString];
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
    [self updateDisplays:nil];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self.brain pushVariable:sender.currentTitle];
    [self updateDisplays:sender.currentTitle];
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
        [self.brain performOperation:sender.currentTitle];
        [self updateDisplays:nil];
    }
}

- (IBAction)clearDisplay {
    [self.brain clearCalculator];
    [self updateDisplays:@"0"];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)setVariableValues:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Test 1"]) {
        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], @"a", [NSNumber numberWithFloat:2.0], @"b", [NSNumber numberWithFloat:3.0], @"x", nil ];
    } else if ([sender.currentTitle isEqualToString:@"Test 2"]) {
        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0], @"a", [NSNumber numberWithFloat:-5.0], @"b", [NSNumber numberWithFloat:0.5], @"x", nil ];
    } else if ([sender.currentTitle isEqualToString:@"Test 3"]) {
        self.testVariableValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], @"a", [NSNumber numberWithFloat:2.0], @"b", [NSNumber numberWithFloat:3.0], @"x", nil ];
    } else if ([sender.currentTitle isEqualToString:@"Test 4"]) {
        self.testVariableValues = nil;
    }
    [self updateDisplays:nil];
}

- (IBAction)undo {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:[self.display.text length]-1];
        if (self.display.text.length == 0) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            [self updateDisplays:nil];
        }
    } else {
        [self.brain undo];
        [self updateDisplays:nil];
    }
}

// Gets GraphViewController if any, that is, if in a split view.
- (CalculatorGraphViewController *)splitViewGraphViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[CalculatorGraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (IBAction)updateGraphView {
    if ([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].program = [self.brain.program copy];
    }
}

#pragma mark -

-(void)awakeFromNib {
    [super awakeFromNib];
    self.title = @"Calculator";
}

- (void)viewDidUnload {
    [self setFullOperationDisplay:nil];
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
