//
//  EventTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAEventTableViewCell.h"
#import "Event.h"

@interface TBAEventTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *datesLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end

@implementation TBAEventTableViewCell

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.nameLabel.text = [event friendlyNameWithYear:NO];
    self.locationLabel.text = event.location;
    self.datesLabel.text = [event dateString];
}

@end
