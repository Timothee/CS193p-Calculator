//
//  GraphViewController.m
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "FavoriteTableViewController.h"

@interface GraphViewController() <GraphingViewDataSource, FavoriteTableViewControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, weak) IBOutlet GraphingCalculatorView *graphView;
@property (nonatomic, strong) UIPopoverController *favoritesPopoverController;
@end

@implementation GraphViewController

@synthesize functionDisplay = _functionDisplay;
@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize favoritesPopoverController = _favoritesPopoverController;

#define FAVORITES_KEY @"GraphViewController.Favorites"

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            [self.favoritesPopoverController dismissPopoverAnimated:NO];
            self.favoritesPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.favoritesPopoverController.delegate = self;
        }
        id destinationVC = segue.destinationViewController;
        FavoriteTableViewController *favoriteTVC;
        if ([destinationVC isKindOfClass:[FavoriteTableViewController class]]) { // iPad
            favoriteTVC = destinationVC;
        } else if ([destinationVC isKindOfClass:[UINavigationController class]]) { // iPhone
            UINavigationController *navigationController = destinationVC;
            favoriteTVC = (FavoriteTableViewController *) navigationController.topViewController;
        }
        favoriteTVC.favorites = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        favoriteTVC.delegate = self;
    }
}

-(IBAction)switchGraphMode {
    if ([self.graphView.graphMode isEqualToString:GRAPH_MODE_LINE]) {
        self.graphView.graphMode = GRAPH_MODE_POINT;
    } else {
        self.graphView.graphMode = GRAPH_MODE_LINE;
    }
}


-(IBAction)addToFavorites {
    if ([self.program count]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
        if (!favorites) favorites = [NSMutableArray array];
        if (![favorites containsObject:self.program]) {
            [favorites addObject:self.program];
            [defaults setObject:favorites forKey:FAVORITES_KEY];
            [defaults synchronize];
        }
    }
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

#pragma mark - FavoriteTableViewControllerDelegate implementation
-(void)favoriteTableViewController:(FavoriteTableViewController *)sender
          didSelectFavoriteProgram:(id)program {
    self.program = program;
    // next two lines rely on the fact that self.favoritesPopoverController is nil if on iPhone
    // and navigationController is nil if on iPad.
    // That works, but is it really proper and clean?
    [self.favoritesPopoverController dismissPopoverAnimated:YES]; // for iPad version
    [sender dismissModalViewControllerAnimated:YES]; // for iPhone version
}

-(void)favoriteTableViewController:(FavoriteTableViewController *)sender
          didDeleteFavoriteProgram:(id)program {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    [favorites removeObject:program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
    sender.favorites = favorites;
}

-(NSArray *)favoritesForFavoriteTableViewController:(FavoriteTableViewController *)sender {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY] copy];
}

#pragma mark - UIPopoverControllerDelegate implementation
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.favoritesPopoverController = nil;
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

@end
