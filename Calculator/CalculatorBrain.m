//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Timothée Boucher on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;

@end

NSSet *validOperations, *twoOperandOperations, *oneOperandOperations, *noOperandOperations;

@implementation CalculatorBrain

@synthesize programStack = _programStack;

+(void) initialize {
    if (!validOperations) {
        validOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"π", @"+/-", @"+", @"-", @"*", @"/" , nil];
        twoOperandOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/" , nil];
        oneOperandOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
        noOperandOperations  = [[NSSet alloc] initWithObjects:@"π", nil];
    }
}

+(BOOL)isVariable:(id)operand {
    return [operand isKindOfClass:[NSString class]] && ![validOperations containsObject:operand];
}

+(BOOL)isOperation:(id)operation {
    return [operation isKindOfClass:[NSString class]] && [validOperations containsObject:operation];
}

-(NSMutableArray *)programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

-(id) program {
    return [self.programStack copy];
}

+(NSString *)descriptionOfTopOfStack:(id)stack previousOperation:(NSString *)previousOperation {
    NSString *result;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack stringValue];
    } else if ([self isVariable:topOfStack]) {
        result =  topOfStack;
    } else if ([self isOperation:topOfStack]) {
        if ([noOperandOperations containsObject:topOfStack]) {
            result = topOfStack;
        } else if ([oneOperandOperations containsObject:topOfStack]) {
            if ([topOfStack isEqualToString:@"+/-"]) topOfStack = @"-";
            result = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack previousOperation:nil]];
        } else {
            NSString *secondPart = [self descriptionOfTopOfStack:stack previousOperation:topOfStack];
            NSString *firstPart = [self descriptionOfTopOfStack:stack previousOperation:topOfStack];
            if ([topOfStack isEqualToString:@"+"] || [topOfStack isEqualToString:@"-"]) {
                if ([previousOperation isEqualToString:@"*"] || [previousOperation isEqualToString:@"/"]) {
                    result = [NSString stringWithFormat:@"(%@ %@ %@)", firstPart, topOfStack, secondPart];
                } else {
                    result = [NSString stringWithFormat:@"%@ %@ %@", firstPart, topOfStack, secondPart];
                }
            } else {
                result = [NSString stringWithFormat:@"%@ %@ %@", firstPart, topOfStack, secondPart];
            }
        }        
    } else {
        result = @"0";
    }
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    NSMutableString *result;
    BOOL firstTimeInLoop = YES;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    while ([stack count]) {
        if (firstTimeInLoop) {
            result = [[self descriptionOfTopOfStack:stack previousOperation:nil] mutableCopy];
            firstTimeInLoop = NO;
        } else {
            [result appendFormat:@", %@", [self descriptionOfTopOfStack:stack previousOperation:nil]];
        }
    }
    return result;
}


-(void) pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void) pushVariable:(NSString *)variable {
    if ([CalculatorBrain isVariable:variable]) {
        [self.programStack addObject:variable];
    }
}


- (double)performOperation:(NSString *)operation
{
    if ([CalculatorBrain isOperation:operation]) {
        [self.programStack addObject:operation];
    }
    return [[self class] runProgram:self.program];
}


-(double) popOperand {
    NSNumber *operandObject = [self.programStack lastObject];
    if (operandObject) [self.programStack removeLastObject];
    return [operandObject doubleValue];
}

+(double) popOperandOffProgramStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -[self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            result = - [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}


+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            if ([self isVariable:[stack objectAtIndex:i]]) {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:[stack objectAtIndex:i]]];
            }
        }
    }
    return [self runProgram:stack];
}


                 
+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *foundVariables = [[NSMutableSet alloc] init]; // do we need the alloc/init here?
    if ([program isKindOfClass:[NSArray class]]) {
        for (id programElement in program) {
            if ([self isVariable:programElement]) {
                [foundVariables addObject:programElement];
            }
        }
    }
    if ([foundVariables count]) {
        return [foundVariables copy]; 
    }
    return nil;
}

-(void) clearCalculator {
    [self.programStack removeAllObjects];
}



@end
