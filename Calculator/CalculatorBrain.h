//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Timothée Boucher on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void) pushOperand:(double)operand;
- (double) performOperation:(NSString *)operation;
- (void) clearCalculator;

@end
