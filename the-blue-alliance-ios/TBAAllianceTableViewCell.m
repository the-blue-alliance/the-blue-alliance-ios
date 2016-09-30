//
//  TBAAllianceCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAllianceTableViewCell.h"
#import "EventAlliance.h"
#import "Team.h"

@interface TBAAllianceTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *allianceNumberLabel;
@property (nonatomic, strong) IBOutlet UIStackView *allianceStackView;

@end

@implementation TBAAllianceTableViewCell

- (void)setEventAlliance:(EventAlliance *)eventAlliance {
    _eventAlliance = eventAlliance;
    
    self.allianceNumberLabel.text = [NSString stringWithFormat:@"Alliance #%@:", eventAlliance.allianceNumber];

    for (UIView *view in self.allianceStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.allianceStackView removeArrangedSubview:view];
    }
    
    // OH PICK BOY http://photos.prnewswire.com/prnvar/20140130/NY56077
    for (Team *team in eventAlliance.picks) {
        UITapGestureRecognizer *teamNumberTapRecogonizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(teamLabelTapped:)];
        [teamNumberTapRecogonizer setNumberOfTapsRequired:1];

        UILabel *pickLabel = [[UILabel alloc] init];
        [pickLabel addGestureRecognizer:teamNumberTapRecogonizer];
        [pickLabel setUserInteractionEnabled:YES];
        pickLabel.textAlignment = NSTextAlignmentCenter;
        [pickLabel setTextColor:[UIColor blueColor]];

        pickLabel.tag = [eventAlliance.picks indexOfObject:team];
        if (team == eventAlliance.picks.firstObject) {
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            pickLabel.attributedText = [[NSAttributedString alloc] initWithString:team.teamNumber.stringValue
                                                                       attributes:underlineAttribute];
        } else {
            pickLabel.text = team.teamNumber.stringValue;
        }
        [self.allianceStackView addArrangedSubview:pickLabel];
    }
}

- (void)teamLabelTapped:(UITapGestureRecognizer *)sender {
    UILabel *teamLabel = (UILabel *)sender.view;
    self.teamSelected([[self.eventAlliance picks] objectAtIndex:teamLabel.tag]);
}

@end
