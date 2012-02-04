//
//  GraphingCalculatorView.h
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRAPH_MODE_LINE @"line"
#define GRAPH_MODE_POINT @"point"

@class CalculatorGraphView;

@protocol GraphingViewDataSource
-(double) yForXValue:(double)x forGraphingView:(CalculatorGraphView *)sender;
@end



@interface CalculatorGraphView : UIView

@property (nonatomic, weak) IBOutlet id <GraphingViewDataSource> dataSource;
@property (nonatomic, strong) NSString *graphMode;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;
-(void)moveOriginToTripleTapLocation:(UITapGestureRecognizer *)gesture;
-(void)zoomIn:(UITapGestureRecognizer *)gesture;
-(void)zoomOut:(UITapGestureRecognizer *)gesture;
@end
