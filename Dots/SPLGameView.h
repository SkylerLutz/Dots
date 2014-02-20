//
//  SPLGameView.h
//  Dots
//
//  Created by Skyler Lutz on 12/19/13.
//  Copyright (c) 2013 Skyler Lutz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPLGameViewDelegate <NSObject>
@required
- (void)didDelete:(NSArray *)dots cycle:(BOOL)cycle;
@end

@interface SPLGameView : UIView
@property (nonatomic, weak) id<SPLGameViewDelegate> delegate;
@property (assign, nonatomic, readonly) int score;
- (void)startGame;
@end
