//
//  TBAAllianceCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAllianceCell.h"
#import "EventAlliance.h"
#import "Team.h"

@interface TBAAllianceCell ()

@property (nonatomic, weak) IBOutlet UILabel *allianceNumberLabel;
@property (nonatomic, weak) IBOutlet UIStackView *allianceStackView;

@end

@implementation TBAAllianceCell



- (void)setEventAlliance:(EventAlliance *)eventAlliance {
    _eventAlliance = eventAlliance;
    
    self.allianceNumberLabel.text = [NSString stringWithFormat:@"Alliance #%@:", eventAlliance.allianceNumber];

    for (UIView *view in self.allianceStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.allianceStackView removeArrangedSubview:view];
    }
    
    // OH PICK BOY http://photos.prnewswire.com/prnvar/20140130/NY56077
    NSArray *picks = [eventAlliance.picks allObjects];
    for (Team *team in picks) {
        UILabel *pickLabel = [[UILabel alloc] init];
        pickLabel.textAlignment = NSTextAlignmentCenter;
        
        if (team == picks.firstObject) {
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            pickLabel.attributedText = [[NSAttributedString alloc] initWithString:team.teamNumber.stringValue
                                                                       attributes:underlineAttribute];
        } else {
            pickLabel.text = team.teamNumber.stringValue;
        }
        [self.allianceStackView addArrangedSubview:pickLabel];
    }
}

@end
