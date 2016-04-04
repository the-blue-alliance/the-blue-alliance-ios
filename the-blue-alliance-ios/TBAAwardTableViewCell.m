//
//  TBAAwardTableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAwardTableViewCell.h"
#import "Award.h"
#import "AwardRecipient.h"
#import "Team.h"

@interface TBAAwardTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *awardNameLabel;
@property (nonatomic, weak) IBOutlet UIStackView *awardeeStackView;

@end

@implementation TBAAwardTableViewCell

- (void)setAward:(Award *)award {
    _award = award;
    
    self.awardNameLabel.text = _award.name;
    
    for (UIView *view in self.awardeeStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.awardeeStackView removeArrangedSubview:view];
    }
    
    for (AwardRecipient *awardee in _award.recipients.allObjects) {
        UILabel *awardeeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        awardeeLabel.numberOfLines = 0;
        awardeeLabel.font = [UIFont systemFontOfSize:14.0f];
        awardeeLabel.textColor = [UIColor darkGrayColor];
        
        NSString *recipientName;
        if (awardee.name) {
            recipientName = awardee.name;
        } else {
            recipientName = [awardee.team nickname];
        }
        awardeeLabel.text = [NSString stringWithFormat:@"%@ - %@", awardee.team.teamNumber, recipientName];
        
        [self.awardeeStackView addArrangedSubview:awardeeLabel];
        [awardeeLabel sizeToFit];
    }
}

@end
