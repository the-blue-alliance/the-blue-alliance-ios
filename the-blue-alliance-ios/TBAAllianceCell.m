//
//  TBAAllianceCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAllianceCell.h"
#import "EventAlliance.h"

@interface TBAAllianceCell ()

@property (nonatomic, weak) IBOutlet UILabel *allianceNumberLabel;
@property (nonatomic, weak) IBOutlet UIStackView *allianceStackView;

@end

@implementation TBAAllianceCell

- (void)setEventAlliance:(EventAlliance *)eventAlliance {
    _eventAlliance = eventAlliance;
    
    self.allianceNumberLabel.text = [NSString stringWithFormat:@"Alliance #%@:", _eventAlliance.allianceNumber];

    for (UIView *view in self.allianceStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.allianceStackView removeArrangedSubview:view];
    }
    
    for (int i = 0; i < self.eventAlliance.picks.count; i++) {
        NSString *pick = [self.eventAlliance.picks[i] substringFromIndex:3];
        
        UILabel *pickLabel = [[UILabel alloc] init];
        pickLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            pickLabel.attributedText = [[NSAttributedString alloc] initWithString:pick
                                                                     attributes:underlineAttribute];
        } else {
            pickLabel.text = pick;
        }
        [self.allianceStackView addArrangedSubview:pickLabel];
    }
}

@end
