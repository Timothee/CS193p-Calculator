//
//  GraphViewController.m
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController() <GraphingViewDataSource>
@property (nonatomic, weak) IBOutlet GraphingCalculatorView *graphView;
@end

@implementation GraphViewController
@synthesize functionDisplay = _functionDisplay;
@synthesize program = _program;
@synthesize graphView = _graphView;


-(void)setGraphView:(GraphingCalculatorView *)graphView {
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(moveOriginToTripleTapLocation:)];
    [tapGR setNumberOfTapsRequired:3];
    [self.graphView addGestureRecognizer:tapGR];
    self.graphView.dataSource = self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - GraphViewDelegate protocol implementation
-(double)yForXValue:(double)x forGraphingView:(GraphingCalculatorView *)sender {
    id y = [CalculatorBrain runProgram:self.program usingVariableValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x", nil]];
    if ([y isKindOfClass:[NSString class]]) {
        y = [NSNumber numberWithDouble:0.0];
    } else {
        
    }
    return [y doubleValue];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.functionDisplay.text = [NSString stringWithFormat:@"f(x) = %@", [CalculatorBrain descriptionOfProgram:self.program]];
}

- (void)viewDidUnload
{
    [self setFunctionDisplay:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
