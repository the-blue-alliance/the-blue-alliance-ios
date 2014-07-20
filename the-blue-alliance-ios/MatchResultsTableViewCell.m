//
//  MatchTableViewCell.m
//  scout-viewer-2014-ios
//
//  Created by Citrus Circuits on 2/5/14.
//  Copyright (c) 2014 Citrus Circuits. All rights reserved.
//

#import "MatchResultsTableViewCell.h"
#import "Team.h"

@interface MatchResultsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *matchTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *red1Label;
@property (weak, nonatomic) IBOutlet UILabel *red2Label;
@property (weak, nonatomic) IBOutlet UILabel *red3Label;

@property (weak, nonatomic) IBOutlet UILabel *blue1Label;
@property (weak, nonatomic) IBOutlet UILabel *blue2Label;
@property (weak, nonatomic) IBOutlet UILabel *blue3Label;

@property (weak, nonatomic) IBOutlet UILabel *redScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueScoreLabel;

@end

@implementation MatchResultsTableViewCell

- (void)setMatch:(Match *)match {
    _match = match;
    
    
    
    NSArray *redAllianceArray = [match.redAlliance array];
    NSArray *blueAllianceArray = [match.blueAlliance array];
    
    BOOL isOfficial = match.blueScoreValue != -1 && match.redScoreValue != -1;
    BOOL redWin = NO; // They are both YES if it is a tie
    BOOL blueWin = NO;
    NSString *redScoreText;
    NSString *blueScoreText;
    if(isOfficial) {
        redScoreText = [match.redScore description];
        blueScoreText = [match.blueScore description];
        if(match.redScoreValue > match.blueScoreValue) {
            redWin = YES;
        } else if(match.redScoreValue < match.blueScoreValue) {
            blueWin = YES;
        } else {
            redWin = YES;
            blueWin = YES;
        }
    } else {
        redScoreText = @"?";
        blueScoreText = @"?";
    }
    
    
    self.matchTextLabel.text = match.friendlyMatchName;

    self.red1Label.text = [[redAllianceArray[0] team_number] description];
    self.red2Label.text = [[redAllianceArray[1] team_number] description];
    self.red3Label.text = [[redAllianceArray[2] team_number] description];

    
    self.blue1Label.text = [[blueAllianceArray[0] team_number] description];
    self.blue2Label.text = [[blueAllianceArray[1] team_number] description];
    self.blue3Label.text = [[blueAllianceArray[2] team_number] description];
    
    
    
    static const CGFloat defaultFontSize = 17;
    UIFont *defaultFont = [UIFont systemFontOfSize:defaultFontSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:defaultFontSize];
    
    
    NSMutableAttributedString *redScoreAttributedText = [[NSMutableAttributedString alloc] initWithString:redScoreText];
    NSMutableAttributedString *blueScoreAttributedText = [[NSMutableAttributedString alloc] initWithString:blueScoreText];

    [redScoreAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, redScoreAttributedText.length)];
    [blueScoreAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, blueScoreAttributedText.length)];
    
    if(redWin) {
        [redScoreAttributedText insertAttributedString:[[NSAttributedString alloc] initWithString:@"▸ "] atIndex:0];
        [redScoreAttributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, redScoreAttributedText.length)];
    } else {
        [redScoreAttributedText addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0, redScoreAttributedText.length)];
    }
    
    if(blueWin) {
        [blueScoreAttributedText insertAttributedString:[[NSAttributedString alloc] initWithString:@"▸ "] atIndex:0];
        [blueScoreAttributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, blueScoreAttributedText.length)];
    } else {
        
        [blueScoreAttributedText addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0, blueScoreAttributedText.length)];
    }


    
    self.redScoreLabel.attributedText = redScoreAttributedText;
    self.blueScoreLabel.attributedText = blueScoreAttributedText;

}
@end
