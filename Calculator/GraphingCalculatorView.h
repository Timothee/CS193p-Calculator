//
//  GraphingCalculatorView.h
//  Calculator
//
//  Created by Timothée Boucher on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphingCalculatorView;

@protocol GraphingViewDataSource
-(double) yForXValue:(double)x forGraphingView:(GraphingCalculatorView *)sender;
@end

@interface GraphingCalculatorView : UIView
@property (nonatomic, weak) IBOutlet id <GraphingViewDataSource> dataSource;
-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;
-(void)moveOriginToTripleTapLocation:(UITapGestureRecognizer *)gesture;
@end
