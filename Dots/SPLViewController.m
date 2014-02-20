//
//  SPLViewController.m
//  Dots
//
//  Created by Skyler Lutz on 12/19/13.
//  Copyright (c) 2013 Skyler Lutz. All rights reserved.
//

#import "SPLViewController.h"
#import "SPLGameView.h"
#import "SPLDot.h"

@interface SPLViewController () <SPLGameViewDelegate>

@property (weak, nonatomic) IBOutlet SPLGameView *gameView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;


@end

@implementation SPLViewController


#pragma mark ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameView.delegate = self;
    [self start:nil];
}
#pragma mark Game

- (IBAction)start:(id)sender {
    [self.gameView startGame];
}

#pragma mark SPLGameViewDelegate
- (void)didDelete:(NSArray *)dots cycle:(BOOL)cycle {
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.gameView.score];
    [self.scoreLabel sizeToFit];
    
}
@end
