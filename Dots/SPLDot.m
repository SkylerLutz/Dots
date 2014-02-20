//
//  SPLDot.m
//  Dots
//
//  Created by Skyler Lutz on 12/19/13.
//  Copyright (c) 2013 Skyler Lutz. All rights reserved.
//

#import "SPLDot.h"
@implementation SPLDot
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _selected = NO;
        _circleColor = -1;
    }
    return self;
}

- (BOOL)isEqual:(SPLDot *)dot {
    return [self matchesColorOf:dot] && CGPointEqualToPoint(self.center, dot.center);
}
- (BOOL)matchesColorOf:(SPLDot *)dot {
    if ([dot circleColor] == -1) { // if no color was specified, return yes....this is on purpose
        return YES;
    }
    return self.circleColor == dot.circleColor;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [self setNeedsDisplay];
}

- (UIColor *)randomColor {
    NSInteger num = (self.circleColor == -1) ? arc4random() % 4 : self.circleColor;
    self.circleColor = num;
    switch (num) {
        case 0:
            return [UIColor colorWithRed:51.0/255.0
                                   green:255.0/255.0
                                    blue:51.0/255.0
                                   alpha:(self.selected) ? 1.0 : 0.3];
        case 1:
            return [UIColor colorWithRed:51.0/255.0
                                   green:255.0/255.0
                                    blue:255.0/255.0
                                   alpha:(self.selected) ? 1.0 : 0.5];
        case 2:
            return [UIColor colorWithRed:153.0/255.0
                                   green:51.0/255.0
                                    blue:255.0/255.0
                                   alpha:(self.selected) ? 1.0 : 0.5];
        case 3:
            return [UIColor colorWithRed:255.0/255.0
                                   green:51.0/255.0
                                    blue:153.0/255.0
                                   alpha:(self.selected) ? 1.0 : 0.5];
        default:
            break;
    }
    return [UIColor blackColor];
}

#pragma mark Custom Drawing
- (void)drawRect:(CGRect)rect
{
    
    CGRect border;
    border.size.width = self.bounds.size.width / 2.0;
    border.size.height = self.bounds.size.height / 2.0;
    border.origin.x = self.bounds.origin.x + self.bounds.size.width / 4.0;
    border.origin.y = self.bounds.origin.y + self.bounds.size.height / 4.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self randomColor].CGColor);
    CGContextFillEllipseInRect(context, border);

    CGContextStrokeEllipseInRect(context, border);
}


@end
