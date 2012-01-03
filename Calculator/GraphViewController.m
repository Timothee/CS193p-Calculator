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
@synthesize toolbar = _toolbar;


-(void)setFunctionDisplayText {
    self.functionDisplay.text = [NSString stringWithFormat:@"y = %@", [CalculatorBrain descriptionOfProgram:self.program]];
}

-(void)setProgram:(NSArray *)program {
    if (![program isEqualToArray:_program]) {
        _program = program;
        [self setFunctionDisplayText];
        [self.graphView setNeedsDisplay];
    }
}

-(void)setGraphView:(GraphingCalculatorView *)graphView {
    _graphView = graphView;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *moveOriginGR = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(moveOriginToTripleTapLocation:)];
    [moveOriginGR setNumberOfTapsRequired:3];
    [self.graphView addGestureRecognizer:moveOriginGR];
    
    UITapGestureRecognizer *zoomInGR = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(zoomIn:)];
    [zoomInGR setNumberOfTapsRequired:2];
    [zoomInGR requireGestureRecognizerToFail:moveOriginGR];
    [self.graphView addGestureRecognizer:zoomInGR];
    
    UITapGestureRecognizer *zoomOutGR = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(zoomOut:)];
    [zoomOutGR setNumberOfTapsRequired:1];
    [zoomOutGR setNumberOfTouchesRequired:2];
    [self.graphView addGestureRecognizer:zoomOutGR];
    
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


#pragma mark - UISplitViewControllerDelegate implementation

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:barButtonItem];
    self.toolbar.items = toolbarItems;
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

-(void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFunctionDisplayText];
}

- (void)viewDidUnload
{
    [self setFunctionDisplay:nil];
    [self setProgram:nil];
    [self setGraphView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.splitViewController) {
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            self.toolbar.hidden = NO;
        } else {
            self.toolbar.hidden = YES;
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.splitViewController) {
        // Resizes the graphView after removing/adding the toolbar.
        if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
            self.graphView.bounds = self.view.bounds;
            self.graphView.frame = self.view.bounds;
        } else {
            int toolbarHeight = self.toolbar.bounds.size.height;
            CGRect viewBounds = self.view.bounds;
            self.graphView.frame = CGRectMake(0, toolbarHeight, viewBounds.size.width, viewBounds.size.height - toolbarHeight);
        }
    }
}
@end
