//
//  GraphingCalculatorView.m
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorGraphView.h"
#import "AxesDrawer.h"

@interface CalculatorGraphView()
@property (nonatomic) float scale;
@property (nonatomic) CGPoint origin;
@end

@implementation CalculatorGraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize graphMode = _graphMode;

-(float)scale {
    if (!_scale) {
        _scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"GraphingCalculatorView.scale"];
        if (!_scale) {
            _scale = 10.0;
        }
    }
    return _scale;
}

-(void)setScale:(float)scale {
    if (_scale != scale) {
        _scale = scale;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:_scale forKey:@"GraphingCalculatorView.scale"];
        [prefs synchronize];
        [self setNeedsDisplay];
    }
}

-(void)setScaleAndOriginWithScaleRatio:(float)scaleRatio andPivotPoint:(CGPoint)tapLocation {
    self.origin = CGPointMake(tapLocation.x - scaleRatio*(tapLocation.x - self.origin.x),
                              tapLocation.y - scaleRatio*(tapLocation.y - self.origin.y));
    self.scale *= scaleRatio;
}

-(CGPoint)origin {
    if (CGPointEqualToPoint(_origin, CGPointZero)) {
        _origin.x = [[NSUserDefaults standardUserDefaults] floatForKey:@"GraphingCalculatorView.origin.x"];
        _origin.y = [[NSUserDefaults standardUserDefaults] floatForKey:@"GraphingCalculatorView.origin.y"];
        if (CGPointEqualToPoint(_origin, CGPointZero)) {
            _origin = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        }
    }
    return _origin;
}

-(void)setOrigin:(CGPoint)origin {
    if (!CGPointEqualToPoint(origin, _origin)) {
        _origin = origin;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:_origin.x forKey:@"GraphingCalculatorView.origin.x"];
        [prefs setFloat:_origin.y forKey:@"GraphingCalculatorView.origin.y"];
        [prefs synchronize];
        [self setNeedsDisplay];
    }
}

-(NSString *)graphMode {
    if (!_graphMode) {
        _graphMode = GRAPH_MODE_LINE;
    }
    return _graphMode;
}

-(void)setGraphMode:(NSString *)graphMode {
    _graphMode = graphMode;
    [self setNeedsDisplay];
}


#pragma mark - Gesture recognizers implementation

-(void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        [self setScaleAndOriginWithScaleRatio:gesture.scale andPivotPoint:[gesture locationInView:self]];
        gesture.scale = 1;
    }
}

-(void)pan:(UIPanGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.origin = CGPointMake(self.origin.x+[gesture translationInView:self].x, self.origin.y+[gesture translationInView:self].y);
        [gesture setTranslation:CGPointMake(0.0, 0.0) inView:self];

    }
}

-(void)moveOriginToTripleTapLocation:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
    }
}

-(void)zoomIn:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setScaleAndOriginWithScaleRatio:2.0 andPivotPoint:[gesture locationInView:self]];
    }
}

-(void)zoomOut:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setScaleAndOriginWithScaleRatio:0.5 andPivotPoint:[gesture locationInView:self]];
    }
}

#pragma mark -

-(void)setup {
    self.contentMode = UIViewContentModeRedraw;
}


-(void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    CGFloat screenDensity = [self contentScaleFactor]; // for retina displays

    // (x, y) coordinates in pixels in view. 0 < x, y < 320|480
    // (X, Y) coordinates in graph view
    // X = (x - self.origin.x)/self.scale
    // Y = (self.origin.y - y)/self.scale -> Y goes up from bottom to top, y goes up from top to bottom
    double Y;
    
    if ([self.graphMode isEqualToString:GRAPH_MODE_LINE]) {
        Y = [self.dataSource yForXValue:-self.origin.x/self.scale forGraphingView:self];
        CGContextMoveToPoint(context, 0, self.origin.y-Y*self.scale);
        for (int x = 1; x < rect.size.width*screenDensity; x++) {
            Y = [self.dataSource yForXValue:(x/screenDensity-self.origin.x)/self.scale forGraphingView:self];
            CGContextAddLineToPoint(context, x/screenDensity, self.origin.y-Y*self.scale);
        }
        [[UIColor blueColor] setStroke];
        CGContextDrawPath(context, kCGPathStroke);
    } else {
        [[UIColor blueColor] setFill];
        for (int x = 1; x < rect.size.width*screenDensity; x++) {
            Y = [self.dataSource yForXValue:(x/screenDensity-self.origin.x)/self.scale forGraphingView:self];
            CGContextFillRect(context, CGRectMake((x-0.5)/screenDensity, self.origin.y-Y*self.scale-0.5/screenDensity, 1.0/screenDensity, 1.0/screenDensity));
        }
    }

}

@end
