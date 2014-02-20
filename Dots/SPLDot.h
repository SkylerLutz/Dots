//
//  SPLDot.h
//  Dots
//
//  Created by Skyler Lutz on 12/19/13.
//  Copyright (c) 2013 Skyler Lutz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPLDot : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic) NSInteger circleColor;

- (BOOL)isEqual:(SPLDot *)dot;
- (BOOL)matchesColorOf:(SPLDot *)dot;
@end
