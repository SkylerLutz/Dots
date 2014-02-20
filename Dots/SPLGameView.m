//
//  SPLGameView.m
//  Dots
//
//  Created by Skyler Lutz on 12/19/13.
//  Copyright (c) 2013 Skyler Lutz. All rights reserved.
//

#import "SPLGameView.h"
#import "SPLDot.h"

#define ROWS 5
#define COLUMNS 6
#define BONUS_MULTIPLIER 3

@interface SPLGameView ()
@property (nonatomic) NSMutableArray *dots;
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@property (assign, nonatomic, readwrite) int score;
@property (nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic) UIGravityBehavior *gravity;
@property (nonatomic) UICollisionBehavior *collision;
@property (nonatomic) UIDynamicItemBehavior *dynamicItem;

@property (assign, nonatomic) BOOL allowDuplicates;
@end

@implementation SPLGameView

static const float width = 40.0;
static const CGSize size = {width, width};

#pragma mark UIDynamicAnimator
- (UIDynamicAnimator *)dynamicAnimator {
    
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    }
    return _dynamicAnimator;
}
- (UIGravityBehavior *)gravity {
    
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = 10.0f;
        [self.dynamicAnimator addBehavior:_gravity];
    }
    return _gravity;
}
- (UICollisionBehavior *)collision {
    
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        [self.dynamicAnimator addBehavior:_collision];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        
    }
    return _collision;
}
- (UIDynamicItemBehavior *)dynamicItem {
    if (!_dynamicItem) {
        _dynamicItem = [[UIDynamicItemBehavior alloc] init];
        _dynamicItem.allowsRotation = NO;
        _dynamicItem.density = 20.0;
        [self.dynamicAnimator addBehavior:_dynamicItem];
    }
    return _dynamicItem;
}
- (void)applyBehaviors:(id<UIDynamicItem>)item {
    [self.gravity addItem:item];
    [self.collision addItem:item];
    [self.dynamicItem addItem:item];
}
- (void)removeBehaviors:(id<UIDynamicItem>)item {
    [self.gravity removeItem:item];
    [self.collision removeItem:item];
    [self.dynamicItem removeItem:item];
}
- (NSMutableArray *)dots {
    if (!_dots) {
        _dots = [[NSMutableArray alloc] init];
    }
    return _dots;
}
- (BOOL)dot:(SPLDot *)start isNearDot:(SPLDot *)end {
    
    float deltaY = end.center.y - start.center.y;
    float deltaX = end.center.x - start.center.x;
    float angleInDegrees = atan2(deltaY, deltaX) * 180 / 3.141592653589793;
    
    float rounded_degrees = roundf(fabsf(angleInDegrees) / 45.0) * 45.0;
    return (int)rounded_degrees % 90 == 0 && fabsf(deltaX) < width+5.0 && fabs(deltaY) < width+5.0;
    NSLog(@"angle: %f", rounded_degrees);
    return YES;
}
- (BOOL)isDot:(SPLDot *)dot {
    return dot != nil && [dot class] == [SPLDot class];
}

- (BOOL)hasCycle {
    return !self.allowDuplicates;
}

- (NSArray *)dotsWithColorOfDot:(SPLDot *)dot {
    
    NSMutableArray *bonusDots = [[NSMutableArray alloc] init];
    for (float i = 0; i <= self.frame.size.width; i+=width) {
        for (float j = 0; j <= self.frame.size.height; j+=width) {
            SPLDot *bonus = (SPLDot *)[self hitTest:CGPointMake(i+width/2.0, j+width/2.0) withEvent:nil];
            if ([self isDot:bonus] && ![bonus selected] && [bonus matchesColorOf:dot]) {
                
                [bonusDots addObject:bonus];
            }
        }
    }
    return bonusDots;
}

- (void)startGame {
    self.score = 0;
    SPLDot *temp = [[SPLDot alloc] init];
    NSSet *prev = [NSSet setWithArray:[self dotsWithColorOfDot:temp]];
    [self dropDots:prev replace:NO];
    
    NSLog(@"start");
    for (int j = 0; j < ROWS; j++) {
        double delayInSeconds = j * 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dropRow];
        });
    }
}
- (void)dropRow {
    
    for (int i = 0.0; i < COLUMNS; i++) {
        double delayInSeconds = i*0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dropDot:CGPointMake(i*width, self.frame.origin.y)];
        });
    }
}

- (void)dropDot:(CGPoint)point {
    CGRect rect;
    rect.size = size;
    rect.origin = point;
    SPLDot *dot = [[SPLDot alloc] initWithFrame:rect];
    [self addSubview:dot];
    [self applyBehaviors:dot];
}
#pragma mark Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.allowDuplicates = YES;
    
    NSLog(@"began");
    UITouch *touch = [touches anyObject];
    CGPoint begin = [touch locationInView:self];
    SPLDot *dot = (SPLDot *)[self hitTest:begin withEvent:nil];
    if ([self isDot:dot]) {
        self.start = dot.center;
        dot.selected = YES;
        [self.dots addObject:dot];
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.end = [touch locationInView:self];
    SPLDot *dot = (SPLDot *)[self hitTest:self.end withEvent:nil];
    if ([self isDot:dot]) {
        if ([[self.dots lastObject] matchesColorOf:dot]) {
            if(![self.dots containsObject:dot]){
                if ([self dot:[self.dots lastObject] isNearDot:dot] ) {
                    dot.selected = YES;
                    [self.dots addObject:dot];
                }
            }
            else {
                NSInteger len = [self.dots count];
                if (len > 1 && [dot isEqual:[self.dots objectAtIndex:len-2]]) { // tracing back
                    SPLDot *d = [self.dots lastObject];
                    d.selected = NO;
                    [self.dots removeObjectAtIndex:[self.dots count]-1];
                    self.allowDuplicates = YES;
                }
                else { // some other dot we've added in the past
                    NSLog(@"FOOBAR");
                    
                    if (self.allowDuplicates && ![dot isEqual:[self.dots lastObject]]) {
                        if ([self dot:[self.dots lastObject] isNearDot:dot] ) {
                            //dot.selected = YES;
                            [self.dots addObject:dot];
                            self.allowDuplicates = NO;
                        }
                        
                    }
                }
            }
        }
    }
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"ended");
    
    
    if([self hasCycle]) {

        [self.dots addObjectsFromArray:[self dotsWithColorOfDot:[self.dots firstObject]]];
    }
    
    for (SPLDot *dot in self.dots) {
        dot.selected = NO;
    }
    
    if ([self.dots count] > 1) {
        [self deleteDots:self.dots];
        [self.delegate didDelete:self.dots cycle:[self hasCycle]];
    }
    [self.dots removeAllObjects];
    self.start = CGPointZero;
    self.end = CGPointZero;
    [self setNeedsDisplay];
}
- (void)deleteDots:(NSArray *)dots {
    
    NSSet *set = [NSSet setWithArray:dots];
    self.score+=[set count] * (([self hasCycle]) ? BONUS_MULTIPLIER : 1);
    [self dropDots:(NSSet *)set replace:YES];
}
- (void)dropDots:(NSSet *)set replace:(BOOL)replace {
    int i = 1;
    for (SPLDot *dot in set) {
        i++;
        [self removeBehaviors:dot];
        double delayInSeconds = 0.1*i;
        if (replace) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dropDot:CGPointMake(dot.frame.origin.x, self.frame.origin.y)];
            });
        }
        
        [dot removeFromSuperview];
    }
}
#pragma mark Custom Drawing
- (void)drawRect:(CGRect)rect
{
    if (!CGPointEqualToPoint(self.start, CGPointZero) && !CGPointEqualToPoint(self.end, CGPointZero)) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if ([self.dots count] > 1) {
            for (int i = 0; i < [self.dots count]-1; i++) {
                SPLDot *first = [self.dots objectAtIndex:i];
                SPLDot *second = [self.dots objectAtIndex:i+1];
                CGContextMoveToPoint(context, first.center.x, first.center.y);
                CGContextAddLineToPoint(context, second.center.x, second.center.y);
            }
        }
        else {
            CGContextMoveToPoint(context, self.start.x, self.start.y);
        }
        CGContextAddLineToPoint(context, self.end.x, self.end.y);
        CGContextStrokePath(context);
    }
    
}


@end
