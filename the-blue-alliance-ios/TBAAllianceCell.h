//
//  TBAAllianceCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

@class EventAlliance;
@protocol TBAAllianceCellDelegate;

@interface TBAAllianceCell : TBATableViewCell
@property (nonatomic, weak) id <TBAAllianceCellDelegate> delegate;
@property (nonatomic, strong) EventAlliance *eventAlliance;

@end

@protocol TBAAllianceCellDelegate <NSObject>
@optional
-(void)teamNumberTapped:(NSString *)teamNumber;
@end